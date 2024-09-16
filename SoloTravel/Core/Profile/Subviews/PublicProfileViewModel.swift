//
//  PublicProfileViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/15/24.
//

import SwiftUI

@MainActor
final class PublicProfileViewModel: ObservableObject {
    @Published var meetupImage: UIImage? = nil
    @Published var profileUser: DBUser? = nil
    @Published var user: DBUser? = nil
    @Published var isShowingPersonalMessageView = false
    @Published var conversationId: String?
    @Published var errorMessage: String? = nil
    
    func loadImage(from url: String) async throws {
        meetupImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func getUser(userId: String) async throws {
        do {
            profileUser = try await UserManager.shared.fetchUser(userId: userId)
        } catch {
            errorMessage = "Error fetching user's profile."
        }
    }
    
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loading your account."
        }
    }
    
    
    func createConversation(with profileId: String) async throws -> String? {
        guard let user else {
            errorMessage = "Error loading your account."
            return nil
        }
        
        if (user.userId == profileId) {
            errorMessage = "Cannot create chat with yourself."
        } else {
            do {
                let userIds = [user.userId, profileId]
                let conversationId = try await MessageManager.shared.createConversation(userIds: userIds)
                isShowingPersonalMessageView = true
                return conversationId
            } catch {
                errorMessage = "Error creating chat."
                return nil
            }
        }
        return nil
    }
    
    
    func blockUser(userId: String, blockedUser: String) async throws {
        do {
            try await UserManager.shared.blockUser(userId: userId, blockedUser: blockedUser)
        } catch {
            errorMessage = "Error blocking user."
        }
    }
    
    
    func unblockUser(userId: String, unblockedUser: String) async throws {
        do {
            try await UserManager.shared.unblockUser(userId: userId, blockedUser: unblockedUser)
        } catch {
            errorMessage = "Error unblocking user."
        }
    }
    
}
