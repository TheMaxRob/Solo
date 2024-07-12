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
    
    private func convertToConversationObjects(conversationDicts: [[String:Any]]) -> [Conversation] {
        var conversations = [Conversation]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        for dict in conversationDicts {
            guard
                let conversationId = dict["id"] as? String,
                let userIds = dict["users"] as? [String],
                let lastMessage = dict["last_message"] as? String,
                let timestamp = dict["timestamp"] as? Timestamp
            else {
                print("Data parsing error for dict: \(dict)")
                continue
            }
            
            let createdDate = timestamp.dateValue()
            
            let conversation = Conversation(id: conversationId, userIds: userIds, lastMessage: lastMessage, createdDate: createdDate)
            conversations.append(conversation)
        }
        return conversations
    }
    
    
    func fetchConversation(conversationId: String) async throws -> Conversation {
        let conversationRef = db.collection("conversations").document(conversationId)
        do {
            let documentSnapshot = try await conversationRef.getDocument()
            if documentSnapshot.exists, let data = documentSnapshot.data() {
                let conversation = try documentSnapshot.data(as: Conversation.self)
                return conversation
            } else {
                throw NSError(domain: "com.yourdomain.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "Conversation not found"])
            }
        } catch {
            throw error
        }
    }

    
    
//    private func convertToMeetupObjects(meetupDicts: [[String: Any]]) -> [Meetup] {
//        var meetups = [Meetup]()
//        
//        // Manually decoding because this is making me pull my hair out
//        for dict in meetupDicts {
//            guard
//                let _ = dict["id"] as? String,
//                let title = dict["title"] as? String,
//                let description = dict["description"] as? String?,
//                let city = dict["city"] as? String,
//                let country = dict["country"] as? String,
//                let organizerId = dict["organizer_id"] as? String,
//                let meetSpot = dict["meet_spot"] as? String,
//                let createdDateTimestamp = dict["created_date"] as? Timestamp,
//                let meetTimeTimestamp = dict["meet_time"] as? Timestamp,
//                let attendees = dict["attendees"] as? [String]?,
//                let pendingUsers = dict["pending_users"] as? [String]?
//            else {
//                // Handle missing or incorrect data
//                print("Data parsing error for dict: \(dict)")
//                continue
//            }
//            
//            // Convert FIRTimestamp to Date
//            let createdDate = createdDateTimestamp.dateValue()
//            let meetTime = meetTimeTimestamp.dateValue()
//            
//            // Initialize Meetup object
//            let meetup = Meetup(
//                title: title,
//                description: description,
//                meetTime: meetTime,
//                city: city,
//                country: country,
//                createdDate: createdDate,
//                organizerId: organizerId,
//                meetSpot: meetSpot,
//                attendees: attendees,
//                pendingUsers: pendingUsers
//            )
//            
//            meetups.append(meetup)
//        }
//        return meetups
//    }
    
    
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
        
        do {
            var newMessage = message
            newMessage.id = messageRef.documentID
            try messageRef.setData(from: newMessage)
            let snapshot = try await conversationRef.getDocument()
            if snapshot.exists {
                try await conversationRef.updateData([
                    "last_message" : message.content
                ])
            }
        } catch {
            throw error
        }
    }
    

    func fetchMessages(conversationId: String) async throws -> [Message] {
        let conversationDocRef = db.collection("conversations").document(conversationId)
        let messagesCollectionRef = conversationDocRef.collection("messages")
        
        do {
            let querySnapshot = try await messagesCollectionRef.order(by: "timestamp", descending: false).getDocuments()
            let messages = try querySnapshot.documents.compactMap { document in
                try document.data(as: Message.self)
            }
            
            return messages
            
        } catch {
            print("Error fetching messages: \(error)")
            throw error
        }
    }
    
    
    func deleteMessage(messageId: String) async throws {
        try await db.collection("conversations").document(messageId).delete()
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
