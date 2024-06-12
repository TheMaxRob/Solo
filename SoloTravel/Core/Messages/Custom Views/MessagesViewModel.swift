//
//  MessagesViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var selectedConversationId: String = ""
    @Published var user: DBUser?
    private var listener: ListenerRegistration?

    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func fetchConversations(for userId: String) async throws {
        conversations = try await MessageManager.shared.fetchConversations(userId: userId)
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

    deinit {
        listener?.remove()
    }
}

