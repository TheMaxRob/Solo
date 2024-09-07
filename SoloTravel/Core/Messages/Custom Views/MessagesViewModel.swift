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
    private var listener: ListenerRegistration?

    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func fetchConversations(for userId: String) async throws {
        conversations = try await MessageManager.shared.fetchConversations(userId: userId)
    }
    
    
    func fetchConversationMessagesView(conversationId: String) async throws -> Conversation {
        return try await MessageManager.shared.fetchConversationMessagesView(conversationId: conversationId)
    }
    

    func fetchMessages(conversationId: String) async throws {
        messages = try await MessageManager.shared.fetchMessages(conversationId: conversationId)
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

