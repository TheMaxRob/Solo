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
    private let conversationCollection = Firestore.firestore().collection("conversations")
    private let userCollection = Firestore.firestore().collection("users")
    static var unreadConversations = 0
    
    private init() { }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    
    // Return all conversations a user is part of
    
    func fetchConversations(userId: String) async throws -> [Conversation] {
        let querySnapshot = try await conversationCollection.whereField("users", arrayContains: userId).getDocuments()
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
    
    
    // return a conversation object corresponding to a conversation id
    
    func fetchConversation(conversationId: String) async throws -> Conversation {
        print("fetching conversation with id \(conversationId)")
        print("normal version called – hasUnreadMessages set to false")
        let conversationRef = conversationCollection.document(conversationId)
        let snapshot = try await conversationRef.getDocument()
        if snapshot.exists {
            do {
                try await conversationRef.updateData([
                    Conversation.CodingKeys.hasUnreadMessages.rawValue : false
                ])
                let conversation = try snapshot.data(as: Conversation.self)
                return conversation
            } catch {
                print("Error fetching conversation: \(error)")
            }
        }
        return Conversation(userIds: [], lastMessage: "", createdDate: Date())
    }
    
    
    // This function doesn't update the conversation to being read
    func fetchConversationMessagesView(conversationId: String) async throws -> Conversation {
        print("fetching conversation with id \(conversationId)")
        print("MessagesView version called – hasUnreadMessages not set to false")
        let conversationRef = conversationCollection.document(conversationId)
        let snapshot = try await conversationRef.getDocument()
        if snapshot.exists {
            do {
                let conversation = try snapshot.data(as: Conversation.self)
                return conversation
            } catch {
                print("Error fetchin conversation: \(error)")
            }
        }
        return Conversation(userIds: [], lastMessage: "", createdDate: Date())
    }
    
    
    
    func createConversation(userIds: [String]) async throws -> String? {
        
        // Create conversation document
        if let existingId = try await conversationExistsId(for: userIds) {
            print("Conversation already exists.")
            return existingId
        } else {
            let newConversation = Conversation(
                userIds: userIds,
                lastMessage: "",
                createdDate: Date()
            )
            print("new conversation with id \(newConversation.id)")
            let conversationData = try encoder.encode(newConversation)
            let conversationRef = conversationCollection.document(newConversation.id)
            try await conversationRef.setData(conversationData)
            
            
            // Set conversations in user documents
            for userId in userIds {
                let userRef = userCollection.document(userId)
                
                let documentSnapshot = try await userRef.getDocument()
                
                if documentSnapshot.exists {
                    try await userRef.updateData([
                        "conversations": FieldValue.arrayUnion([newConversation.id])
                    ])
                } else {
                    try await userRef.setData([
                        "conversations": [newConversation.id]
                    ])
                }
            }
            return newConversation.id
        }
    }
        
    func conversationExistsId(for userIds: [String]) async throws -> String? {
        if userIds[0].isEmpty { return nil }
        
        let querySnapshot = try await conversationCollection.whereField("users", arrayContainsAny: userIds).getDocuments()
        
        for document in querySnapshot.documents {
            if let conversation = try? document.data(as: Conversation.self) {
                if Set(conversation.users) == Set(userIds) {
                    return conversation.id
                }
            }
        }
        return nil
    }
    
    
    // Sends message and designates the conversation and user as having unread messages
    func sendMessage(conversationId: String, message: Message, recipientId: String, senderId: String) async throws {
        let conversationRef = conversationCollection.document(conversationId)
        
        let messagesRef = conversationRef.collection("messages")
        
        // Add the message document to the messages subcollection
        do {
            try await messagesRef.addDocument(data: [
                Message.CodingKeys.senderId.rawValue : message.senderId,
                Message.CodingKeys.recipientId.rawValue : message.recipientId,
                Message.CodingKeys.content.rawValue : message.content,
                Message.CodingKeys.timestamp.rawValue : message.timestamp
            ])
            
            // Update the conversation document with the latest message information
            try await conversationRef.updateData([
                Conversation.CodingKeys.hasUnreadMessages.rawValue : true,
                Conversation.CodingKeys.lastMessage.rawValue : message.content,
                Conversation.CodingKeys.mostRecentSenderId.rawValue : senderId
            ])
            
            // Update recipient to have unread conversation
            let userRef = userCollection.document(recipientId)
            let userSnapshot = try await userRef.getDocument()
            if userSnapshot.exists {
                try await userRef.updateData([
                    DBUser.CodingKeys.hasUnreadMessages.rawValue : true
                ])
            }
            
            
        } catch {
            
        }
       
        
        
    }

    

    // fetch all messages for a given conversation id
    func fetchMessages(conversationId: String) async throws -> [Message] {
        print("conversationId in fetchMessages Manager: \(conversationId)")
        if conversationId.isEmpty {
            print("Cannot find conversationId – fetchMessages")
            return []
        }
        
        let conversationRef = conversationCollection.document(conversationId)
        let messagesRef = conversationRef.collection("messages")
        
        do {
            // Fetch messages from the subcollection
            let querySnapshot = try await messagesRef.order(by: "timestamp").getDocuments()
            
            var messages: [Message] = []
            for document in querySnapshot.documents {
                // Decode the message from the document snapshot
                do {
                    let message = try document.data(as: Message.self)
                    messages.append(message)
                    
                } catch {
                    print("Error decoding message document \(document.documentID): \(error)")
                }
               
            }
            
            return messages
        } catch {
            print("Error fetching messages: \(error)")
            throw error
        }
    }


    
    
    func setMessagesRead(conversationId: String) async throws {
        let conversationRef = conversationCollection.document(conversationId)
        let snapshot = try await conversationRef.getDocument()
        if snapshot.exists {
            try await conversationRef.updateData([
                Conversation.CodingKeys.hasUnreadMessages.rawValue : false
            ])
        }
    }
    
    
    func deleteMessage(messageId: String) async throws {
        try await conversationCollection.document(messageId).delete()
    }
    
    
    func deleteConversation(conversationId: String) async throws {
        let convRef = conversationCollection.document(conversationId)
            let convSnapshot = try await convRef.getDocument()
            if convSnapshot.exists {
                if let userIds = convSnapshot.data()?["users"] as? [String] {
                    for userId in userIds {
                        let userRef = userCollection.document(userId)
                        let userSnapshot = try await userRef.getDocument()
                        if userSnapshot.exists {
                            try await userRef.updateData([
                                "conversations" : FieldValue.arrayRemove([conversationId])
                            ])
                        } else {
                            print("user document does not exist.")
                        }
                    }
                }
            } else {
                print("No conversation doc found.")
            }
            try await convRef.delete()
        }
}
