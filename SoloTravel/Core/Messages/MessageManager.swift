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
        db.collection("conversations")
            .whereField("users", arrayContains: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No conversations found")
                    return
                }
                let conversations = documents.compactMap { document -> Conversation? in
                    try? document.data(as: Conversation.self)
                }
                completion(conversations)
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
    
    func fetchMessages(conversationId: String, completion: @escaping ([Message]) -> Void) {
            db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .order(by: "timestamp")
                .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("No messages found")
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
            let conversation = Conversation(users: userIds, lastMessage: nil, timestamp: Timestamp())
            let ref = try db.collection("conversations").addDocument(from: conversation)
            return ref.documentID
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

