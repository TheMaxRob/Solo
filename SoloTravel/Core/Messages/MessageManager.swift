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
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    func fetchConversations(userId: String) async throws -> [Conversation] {
        let ref = db.collection("conversations")
        
        let querySnapshot = try await ref.whereField("users", arrayContains: userId).getDocuments()
        
        var conversations: [Conversation] = []
        
        for document in querySnapshot.documents {
            if let conversation = try? document.data(as: Conversation.self) {
                conversations.append(conversation)
            } else {
                print("Error decoding document into Conversation: \(document.documentID)")
            }
        }
        return conversations
    }
    
//    private func convertToConversationObjects(conversationDicts: [[String:Any]]) -> [Conversation] {
//        var conversations = [Conversation]()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//        
//        for dict in conversationDicts {
//            guard
//                let conversationId = dict["id"] as? String,
//                let userIds = dict["users"] as? [String],
//                let lastMessage = dict["last_message"] as? String,
//                let timestamp = dict["timestamp"] as? Timestamp
//            else {
//                print("Data parsing error for dict: \(dict)")
//                continue
//            }
//            
//            let createdDate = timestamp.dateValue()
//            
//            let conversation = Conversation(id: conversationId, userIds: userIds, lastMessage: lastMessage, createdDate: createdDate)
//            conversations.append(conversation)
//        }
//        return conversations
//    }

    
    
    private func convertToMeetupObjects(meetupDicts: [[String: Any]]) -> [Meetup] {
        var meetups = [Meetup]()
        
        
        // Manually decoding because this is making me pull my hair out
        for dict in meetupDicts {
            guard
                let id = dict["id"] as? String,
                let title = dict["title"] as? String,
                let description = dict["description"] as? String?,
                let city = dict["city"] as? String,
                let organizerId = dict["organizerId"] as? String,
                let meetSpot = dict["meetSpot"] as? String,
                let createdDateTimestamp = dict["createdDate"] as? Timestamp,
                let meetTimeTimestamp = dict["meetTime"] as? Timestamp
            else {
                // Handle missing or incorrect data
                print("Data parsing error for dict: \(dict)")
                continue
            }
            
            // Convert FIRTimestamp to Date
            let createdDate = createdDateTimestamp.dateValue()
            let meetTime = meetTimeTimestamp.dateValue()
            
            // Initialize Meetup object
            let meetup = Meetup(
                id: id,
                title: title,
                description: description,
                meetTime: meetTime,
                city: city,
                createdDate: createdDate,
                organizerId: organizerId,
                meetSpot: meetSpot
            )
            
            meetups.append(meetup)
        }
        return meetups
    }
    
    
    func createConversation(userIds: [String]) async throws -> String? {
        if let existingId = try await conversationExistsId(for: userIds) {
            print("Conversation already exists.")
            return existingId
        } else {
            let newConversationId = UUID().uuidString
            let newConversation = Conversation(
                id: newConversationId,
                userIds: userIds,
                lastMessage: "",
                createdDate: Date()
            )
            
            let conversationRef = db.collection("conversations").document(newConversationId)
            try await conversationRef.setData([
                "id": newConversation.id,
                "users": newConversation.users,
                "last_message": newConversation.lastMessage ?? "",
                "timestamp": newConversation.timestamp ?? FieldValue.serverTimestamp()
            ])
            
            for userId in userIds {
                let userRef = db.collection("users").document(userId)
                
                let documentSnapshot = try await userRef.getDocument()
                
                if documentSnapshot.exists {
                    try await userRef.updateData([
                        "conversations": FieldValue.arrayUnion([newConversationId])
                    ])
                } else {
                    try await userRef.setData([
                        "conversations": [newConversationId]
                    ])
                }
            }
            return newConversationId
        }
    }
        
    func conversationExistsId(for userIds: [String]) async throws -> String? {
        if userIds[0].isEmpty { return nil }
        
        let ref = db.collection("conversations")
        
        let querySnapshot = try await ref.whereField("users", arrayContainsAny: userIds).getDocuments()
        
        for document in querySnapshot.documents {
            if let conversation = try? document.data(as: Conversation.self) {
                if Set(conversation.users) == Set(userIds) {
                    return conversation.id
                }
            }
        }
        return nil
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
