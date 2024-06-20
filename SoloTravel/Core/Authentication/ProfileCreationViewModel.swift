//
//  ProfileCreationViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import Foundation

final class ProfileCreationViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var homeCountry: String = ""
    @Published var birthDate: Date = Date()
    @Published var bio: String = "Tell us about yourself!"
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func saveUserProfile() async throws {
        try await UserManager.shared.createUserProfile(userId: user?.userId ?? "", firstName: firstName, lastName: lastName, country: homeCountry, bio: bio, birthDate: birthDate)
    }
}
