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
    @Published var user: DBUser?
    @Published var other: DBUser?
    @Published var profileImage: UIImage? = nil
    @Published var isLoadingUsers: Bool = true
    @Published var errorMessage: String? = nil
    
    
    func canSendMessage() -> Bool {
        guard let user = user, let other = other else {
            return false
        }
        
        let isBlockedByOther = other.blockedUsers?.contains(user.userId)
        let hasBlockedOther = user.blockedUsers?.contains(other.userId)
        
        return !(isBlockedByOther == true || hasBlockedOther == true)
    }
    
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loding your account."
        }
    }
    
    
    func fetchConversation(conversationId: String) async throws -> Conversation? {
        do {
            let conversation = try await MessageManager.shared.fetchConversation(conversationId: conversationId)
            
            for userId in conversation.users {
                if userId != self.user?.userId {
                    other = try await UserManager.shared.fetchUser(userId: userId)
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


