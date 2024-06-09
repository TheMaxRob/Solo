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
        let userRef = db.collection("users").document(userId)
        let documentSnapshot = try await userRef.getDocument()
        
        if documentSnapshot.exists {
            guard let conversationsData = documentSnapshot.get("conversations") as? [[String:Any]] else {
                print("Error getting conversation data.")
                return []
            }
            let conversations = convertToConversationObjects(conversationDicts: conversationsData)
            return conversations
        } else {
            print("No conversation found.")
            return []
        }
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
        let conversation = Conversation(id: UUID().uuidString, userIds: userIds, lastMessage: "", createdDate: Date())
        if let existingId = try await conversationExistsId(for: userIds) {
            print("Conversation already exists.")
            return existingId
        } else {
            for userId in userIds {
                let userRef = db.collection("users").document(userId)
                
                let documentSnapshot = try await userRef.getDocument()
                
                if documentSnapshot.exists {
                    try await userRef.updateData([
                        "conversations" : FieldValue.arrayUnion([try encoder.encode(conversation)])
                    ])
                } else {
                    try await userRef.setData([
                        "conversations" : [try encoder.encode(conversation)]
                    ])
                }
            }
        }
        return nil
    }
        
    func conversationExistsId(for userIds: [String]) async throws -> String? {
        guard let firstUserId = userIds.first else { return nil }
        
        let userRef = db.collection("users").document(firstUserId)
        
        let documentSnapshot = try await userRef.getDocument()
        
        if documentSnapshot.exists {
            if let conversationsData = documentSnapshot.get("conversations") as? [Any] {
                for item in conversationsData {
                    if let conversationDict = item as? [String: Any] {
                        do {
                            guard let conversationId = conversationDict["id"] as? String else {
                                print("Conversation ID is missing")
                                continue
                            }
                            let conversation = try Conversation(from: conversationDict as! Decoder)
                            let conversationUserIds = Set(conversation.users)
                            let inputUserIds = Set(userIds)
                            
                            if conversationUserIds == inputUserIds {
                                print("Matching user arrays found - returning existing conversationId")
                                return conversationId
                            }
                        } catch {
                            print("Error decoding conversation: \(error)")
                        }
                    } else {
                        print("Invalid format in conversation array.")
                    }
                }
            } else {
                print("Conversations field is missing or not an array")
            }
        } else {
            print("User Document does not exist.")
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
