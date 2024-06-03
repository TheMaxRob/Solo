//
//  MessageManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MessageManager {
    static let shared = MessageManager()
    private let db = Firestore.firestore()
    
    private init() { }
    
    func fetchConversations(userId: String, completion: @escaping ([Conversation]) -> Void) {
        let conversationsRef = db.collection("conversations")
        conversationsRef
            .whereField("users", arrayContains: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No conversations found, creating a new conversation")
                    self.createInitialConversation(for: userId, completion: completion)
                    return
                }
                let conversations = documents.compactMap { document -> Conversation? in
                    try? document.data(as: Conversation.self)
                }
                completion(conversations)
            }
    }

    private func createInitialConversation(for userId: String, completion: @escaping ([Conversation]) -> Void) {
        let conversation = Conversation(users: [userId], lastMessage: nil, timestamp: Timestamp())
        do {
            let ref = try db.collection("conversations").addDocument(from: conversation)
            // Fetch the newly created conversation
            ref.getDocument { document, error in
                guard let document = document, document.exists, let conversation = try? document.data(as: Conversation.self) else {
                    print("Error fetching the newly created conversation: \(String(describing: error))")
                    completion([])
                    return
                }
                completion([conversation])
            }
        } catch {
            print("Error creating initial conversation: \(error)")
            completion([])
        }
    }

    
    func sendMessage(conversationId: String, message: Message) async throws {
            let conversationRef = db.collection("conversations").document(conversationId)
            let messageRef = conversationRef.collection("messages").document()

            try await db.runTransaction { (transaction, errorPointer) -> Any? in
                transaction.setData(message.toDictionary(), forDocument: messageRef)
                transaction.updateData([
                    "last_message": message.content,
                    "timestamp": message.timestamp
                ], forDocument: conversationRef)
                return nil
            }
        }
    
    @discardableResult
    func fetchMessages(conversationId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No messages found")
                    completion([])
                    return
                }
                let messages = documents.compactMap { document -> Message? in
                    try? document.data(as: Message.self)
                }
                completion(messages)
            }
    }


        // Create a new conversation
    func createConversation(userIds: [String]) async throws -> String {
        
        // Check if a conversation already exists between the specified users
        if let existingConversationId = try await findExistingConversationId(for: userIds) {
            // Return the ID of the existing conversation
            return existingConversationId
        }
        
        // If no existing conversation found, create a new conversation
        let conversation = Conversation(users: userIds, lastMessage: nil, timestamp: Timestamp())
        let ref = try db.collection("conversations").addDocument(from: conversation)
        return ref.documentID
    }

    private func findExistingConversationId(for userIds: [String]) async throws -> String? {
        let firstUserId = userIds.first ?? ""
        
        // Perform a query that checks if the first user ID is in the 'users' array
        let querySnapshot = try await db.collection("conversations")
            .whereField("users", arrayContains: firstUserId)
            .getDocuments()
        
        // If there are no documents, return nil
        guard !querySnapshot.isEmpty else {
            print("querySnapshot is empty – returning nil")
            return nil
        }
        
        // Filter the results client-side to find a conversation with both user IDs
        for document in querySnapshot.documents {
            let conversation = try document.data(as: Conversation.self)
            if Set(conversation.users).isSuperset(of: Set(userIds)) {
                return document.documentID
            }
        }
        
        print("No matching conversation found – returning nil")
        return nil
    }

}

    extension Encodable {
        func toDictionary() -> [String: Any] {
            guard let data = try? JSONEncoder().encode(self),
                  let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                return [:]
            }
            return dictionary
        }
    }

