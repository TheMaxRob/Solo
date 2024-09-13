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
    
    
    func canSendMessage() -> Bool {
        guard let user = user, let other = other else {
            return false
        }
        
        let isBlockedByOther = other.blockedUsers?.contains(user.userId)
        let hasBlockedOther = user.blockedUsers?.contains(other.userId)
        
        return !(isBlockedByOther == true || hasBlockedOther == true)
    }
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func fetchConversation(conversationId: String) async throws -> Conversation? {
        do {
            let conversation = try await MessageManager.shared.fetchConversation(conversationId: conversationId)
            
            // Debugging prints
            print("conversation.users: \(conversation.users)")
            print("current user id: \(self.user?.userId)")
            
            for userId in conversation.users {
                if userId != self.user?.userId {
                    print("Assigning other")
                    other = try await UserManager.shared.getUser(userId: userId)
                    print("other id: ", other?.id)
                    return conversation
                }
            }
            
    
            print("No valid other user found")
            return nil
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    
    
    func deleteConversation(conversationId: String) async throws {
        try await MessageManager.shared.deleteConversation(conversationId: conversationId)
    }

    
    func fetchMessages(conversationId: String) async throws {
        print("conversationId in fetchMessages viewModel: \(conversationId)")
        conversation.messages = try await MessageManager.shared.fetchMessages(conversationId: conversationId)
        print("conversation.messages: ", conversation.messages)
        for message in conversation.messages ?? [] {
            // Delete messages older than one week
            if message.timestamp < Date().addingTimeInterval(-7 * 24 * 60 * 60) {
                try? await deleteMessage(messageId: message.id ?? "")
            }
        }
    }
    

    func sendMessage(to conversationId: String, content: String, senderId: String, recipientId: String) async throws {
        let message = Message(senderId: senderId, recipientId: recipientId, content: content, timestamp: Date())
        do {
            conversation.messages?.append(message)
            try await MessageManager.shared.sendMessage(conversationId: conversationId, message: message, recipientId: recipientId, senderId: senderId)
            conversation.lastMessage = content
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    
    func setMessagesRead(conversationId: String) async throws {
        try await MessageManager.shared.setMessagesRead(conversationId: conversationId)
    }
    
    
    func deleteMessage(messageId: String) async throws {
        try await MessageManager.shared.deleteMessage(messageId: messageId)
    }
}


