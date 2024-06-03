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
    @Published var selectedConversation: Conversation?
    private var listener: ListenerRegistration?

    func fetchConversations(for userId: String) {
        MessageManager.shared.fetchConversations(userId: userId) { [weak self] conversations in
            self?.conversations = conversations
        }
    }

    func fetchMessages(for conversationId: String) {
        listener?.remove() // Remove any existing listener
        listener = MessageManager.shared.fetchMessages(conversationId: conversationId) { [weak self] messages in
            self?.messages = messages
        }
    }

    func sendMessage(to conversationId: String, content: String, senderId: String, recipientId: String) async {
        let message = Message(senderId: senderId, recipientId: recipientId, content: content, timestamp: Timestamp())
        do {
            try await MessageManager .shared.sendMessage(conversationId: conversationId, message: message)
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    deinit {
        listener?.remove()
    }
}

