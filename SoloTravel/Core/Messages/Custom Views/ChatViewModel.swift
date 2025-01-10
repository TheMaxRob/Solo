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
    @Published var conversation: Conversation = Conversation(userIds: [], lastMessage: "", createdDate: Date())
    @Published var other: DBUser?
    @Published var profileImage: UIImage? = nil
    @Published var isLoadingUsers: Bool = true
    @Published var errorMessage: String? = nil
    
    
    func canSendMessage(user: DBUser) -> Bool {
        let isBlockedByOther = other?.blockedUsers?.contains(user.userId)
        let hasBlockedOther = user.blockedUsers?.contains(other?.userId ?? "")
        
        return !(isBlockedByOther == true || hasBlockedOther == true)
    }
    
    func fetchConversation(conversationId: String, userId: String) async throws -> Conversation? {
        do {
            let conversation = try await MessageManager.shared.fetchConversation(conversationId: conversationId)
            
            for otherUserId in conversation.users {
                // This would need to change to accommodate group messaging
                if otherUserId != userId {
                    other = try await UserManager.shared.fetchUser(userId: otherUserId)
                    print("other User: \(String(describing: other?.userId))")
                    return conversation
                }
            }
            print("No valid other user found")
            return nil
        } catch {
            errorMessage = "Error loading this conversation."
            return nil
        }
    }

    
    
    func deleteConversation(conversationId: String) async throws {
        do {
            try await MessageManager.shared.deleteConversation(conversationId: conversationId)
        } catch {
            print("Error deleting conversation \(conversationId): \(error)")
        }
    }

    
    func fetchMessages(conversationId: String) async throws {
        do {
            conversation.messages = try await MessageManager.shared.fetchMessages(conversationId: conversationId)
            for message in conversation.messages ?? [] {
                // Delete messages older than one week
                if message.timestamp < Date().addingTimeInterval(-7 * 24 * 60 * 60) {
                    try? await deleteMessage(messageId: message.id ?? "")
                }
            }
        } catch {
            errorMessage = "Error fetching messages."
        }
    }
    

    func sendMessage(to conversationId: String, content: String, senderId: String, recipientId: String) async throws {
        let message = Message(senderId: senderId, recipientId: recipientId, content: content, timestamp: Date())
        do {
            conversation.messages?.append(message)
            try await MessageManager.shared.sendMessage(conversationId: conversationId, message: message, recipientId: recipientId, senderId: senderId)
            conversation.lastMessage = content
        } catch {
            errorMessage = "Failed to send message."
        }
    }
    
    
    func setMessagesRead(conversationId: String) async throws {
        try await MessageManager.shared.setMessagesRead(conversationId: conversationId)
    }
    
    
    func deleteMessage(messageId: String) async throws {
        try await MessageManager.shared.deleteMessage(messageId: messageId)
    }
}


