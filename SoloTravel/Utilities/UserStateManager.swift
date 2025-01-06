//
//  UserStateManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 9/29/24.
//

import SwiftUI

@MainActor
final class UserStateManager: ObservableObject {
    @Published var currentUser: DBUser?
    @Published var profileImage: UIImage? // Cache for the profile picture
    
    func updateUser(_ user: DBUser) {
        self.currentUser = user
    }
    
    func loadUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.currentUser = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        
        // Load and cache the profile image
        if let profileImageUrl = currentUser?.photoURL {
            try await loadProfileImage(from: currentUser?.photoURL ?? "")
        }
    }
    
    func refreshUser() async throws {
        guard let userId = currentUser?.userId else { return }
        self.currentUser = try await UserManager.shared.fetchUser(userId: userId)
        
        // Refresh and cache the profile image
        if let profileImageUrl = currentUser?.photoURL {
            try await loadProfileImage(from: currentUser?.photoURL ?? "")
        }
    }
    
    private func loadProfileImage(from url: String) async throws {
        guard let imageURL = URL(string: url) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloadedImage = UIImage(data: data) {
                self.profileImage = downloadedImage
            }
        } catch {
            print("Failed to load profile image: \(error)")
            self.profileImage = nil // Clear cache on failure
        }
    }
}

