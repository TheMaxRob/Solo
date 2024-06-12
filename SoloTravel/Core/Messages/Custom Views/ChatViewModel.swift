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
    
    func loadCurrentUser() async throws {
        print("loadCurrentUser")
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        print("self.user assigned - Returning")
    }
    
    
    func fetchConversation(conversationId: String) async throws -> Conversation {
        return try await MessageManager.shared.fetchConversation(conversationId: conversationId)
    }

    
    func fetchMessages(conversationId: String) async throws {
        messages = try await MessageManager.shared.fetchMessages(conversationId: conversationId)
    }

    func sendMessage(to conversationId: String, content: String, senderId: String, recipientId: String) async throws {
        let message = Message(senderId: senderId, recipientId: recipientId, content: content, timestamp: Timestamp())
        do {
            try await MessageManager.shared.sendMessage(conversationId: conversationId, message: message)
        } catch {
            print("Failed to send message: \(error)")
        }
    }
}


