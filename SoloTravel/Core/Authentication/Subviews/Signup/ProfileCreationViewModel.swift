//
//  ProfileCreationViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import Foundation
import _PhotosUI_SwiftUI

@MainActor
final class ProfileCreationViewModel: ObservableObject {
    @Published var user: DBUser = DBUser(userId: "")
    // @Published var isShowingProfilePictureCreationView: Bool = false
    
    var firstName: String = ""
    var lastName: String = ""
    var homeCountry: String = ""
    var age: String = ""
    var bio: String = "Tell us about yourself!"
    @Published var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var isShowingWelcomeView: Bool = false
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func saveUserProfile() async throws {
        let photoURL = try await UserManager.shared.uploadImageToFirebase((selectedImage ?? UIImage(systemName: "person.circle")!))
        print("uploadImagetoFirebase successful")
        try await UserManager.shared.createUserProfile(userId: user.userId, firstName: firstName, lastName: lastName, country: homeCountry, bio: bio, age: age, photoURL: photoURL)
    }
    
    
    func loadImage(from item: PhotosPickerItem?) async throws  -> UIImage? {
        guard let item = item else { return nil }
        
        let imageData = try? await item.loadTransferable(type: Data.self)
        if let data = imageData, let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
}
