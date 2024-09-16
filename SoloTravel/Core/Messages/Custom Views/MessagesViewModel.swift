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
    @Published var userNames: [String] = []
    @Published var errorMessage: String? = nil
    private var listener: ListenerRegistration?

    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loading your account."
        }
    }
    
    
    func fetchConversations(for userId: String) async throws {
        do {
            conversations = try await MessageManager.shared.fetchConversations(userId: userId)
        } catch {
            errorMessage = "There was an error loading your conversations."
        }
    }
    
    
    func fetchConversationMessagesView(conversationId: String) async throws -> Conversation {
        do {
            return try await MessageManager.shared.fetchConversationMessagesView(conversationId: conversationId)
        } catch {
            errorMessage = "There was an error loading your conversations."
            return Conversation(userIds: [], lastMessage: "", createdDate: Date())
        }
    }
    

    func fetchMessages(conversationId: String) async throws {
        do {
            messages = try await MessageManager.shared.fetchMessages(conversationId: conversationId)
        } catch {
            errorMessage = "There was an error loading messages."
        }
    }
    
    
    func fetchUserNames(userIds: [String]) async throws {
        let filteredUserIds = userIds.filter { $0 != user?.userId }
        print("filteredUserIds: ", filteredUserIds)
        userNames = try await UserManager.shared.fetchUserNames(userIds: filteredUserIds)
    }
    
    
    func setUserMessagesRead(userId: String) async throws {
        try await UserManager.shared.setUserMessagesRead(userId: userId)
    }

    deinit {
        listener?.remove()
    }
}

