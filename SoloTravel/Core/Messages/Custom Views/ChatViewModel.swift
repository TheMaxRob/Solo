//
//  ChatViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var user: DBUser?
    @Published var other: DBUser?
    
    func loadCurrentUser() async throws {
        print("loadCurrentUser")
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        print("self.user assigned - Returning")
    }
    
    
    func fetchConversation(conversationId: String) async throws -> Conversation {
        let conversation = try await MessageManager.shared.fetchConversation(conversationId: conversationId)
        for id in conversation.users {
            if (id != user?.userId) {
                other = try await UserManager.shared.getUser(userId: id)
                break
            }
        }
        return conversation
    }
    
    
    func deleteConversation(conversationId: String) async throws {
        try await MessageManager.shared.deleteConversation(conversationId: conversationId)
    }

    
    func fetchMessages(conversationId: String) async throws {
        messages = try await MessageManager.shared.fetchMessages(conversationId: conversationId)
        for message in messages {
            let date = message.timestamp.dateValue()
            
            // Delete messages older than one week
            if date < Date().addingTimeInterval(-7 * 24 * 60 * 60) {
                try? await deleteMessage(messageId: message.id ?? "")
            }
        }
    }
    

    func sendMessage(to conversationId: String, content: String, senderId: String, recipientId: String) async throws {
        let message = Message(senderId: senderId, recipientId: recipientId, content: content, timestamp: Timestamp())
        do {
            try await MessageManager.shared.sendMessage(conversationId: conversationId, message: message)
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    
    func deleteMessage(messageId: String) async throws {
        try await MessageManager.shared.deleteMessage(messageId: messageId)
    }
    
    
    
    
}


