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
    var bio: String = "Tell other users about yourself – hobbies and interests encouraged!"
    @Published var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var isShowingWelcomeView: Bool = false
    @Published var errorMessage: String? = nil
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            print("authDataResult created")
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            handleError(error)
        }
    }
    
    
    func saveUserProfile() async throws {
        do {
            let photoURL = try await UserManager.shared.uploadImageToFirebase((selectedImage ?? UIImage(systemName: "person.circle")!))
            print("uploadImagetoFirebase successful")
            try await UserManager.shared.createUserProfile(userId: user.userId, firstName: firstName, lastName: lastName, country: homeCountry, bio: bio, age: age, photoURL: photoURL)
        } catch {
            handleError(error)
        }
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
    
    private func handleError(_ error: Error) {
        if let userError = error as? UserManagerError {
            switch userError {
            case .invalidUserId:
                errorMessage = "Invalid user ID. Please try again."
            case .userNotFound:
                errorMessage = "User not found. Please check your credentials."
            case .firestoreError:
                errorMessage = "Something went wrong on our end, please try again later."
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

}
