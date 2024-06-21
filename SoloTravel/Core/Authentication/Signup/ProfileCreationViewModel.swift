//
//  ProfileCreationViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import Foundation

@MainActor
final class ProfileCreationViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var isShowingProfilePictureCreationView: Bool = false
    
    var firstName: String = ""
    var lastName: String = ""
    var homeCountry: String = ""
    var age: String = ""
    var bio: String = "Tell us about yourself!"
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func saveUserProfile() async throws {
        try await UserManager.shared.createUserProfile(userId: user?.userId ?? "", firstName: firstName, lastName: lastName, country: homeCountry, bio: bio, age: age)
    }
}
