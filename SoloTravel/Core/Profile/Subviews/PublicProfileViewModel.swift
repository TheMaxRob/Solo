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
    
    func loadImage(from url: String) async throws {
        meetupImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func getUser(userId: String) async throws {
        profileUser = try await UserManager.shared.getUser(userId: userId)
        print("profileUser: \(String(describing: profileUser))")
    }
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func createConversation(with profileId: String) async throws -> String? {
        guard let user else { return nil }
        
        if (user.userId == profileId) {
            print("Cannot create chat with yourself.")
            return nil
        } else {
            let userIds = [user.userId, profileId]
            let conversationId = try await MessageManager.shared.createConversation(userIds: userIds)
            isShowingPersonalMessageView = true
            return conversationId
        }
    }
    
}
