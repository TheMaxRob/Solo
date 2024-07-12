//
//  EditUserProfileView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/8/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
final class EditUserProfileViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var homeCountry: String = ""
    @Published var bio: String = ""
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil

    
    func loadImage(from item: PhotosPickerItem?) async throws  -> UIImage? {
        guard let item = item else { return nil }
        
        let imageData = try? await item.loadTransferable(type: Data.self)
        if let data = imageData, let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
    
    
    func saveChanges(userId: String) async throws {
        var updateFields = [String: Any]()
               
        if !firstName.isEmpty {
                    updateFields[DBUser.CodingKeys.firstName.rawValue] = firstName
                }
                if !lastName.isEmpty {
                    updateFields[DBUser.CodingKeys.lastName.rawValue] = lastName
                }
                if !email.isEmpty {
                    updateFields[DBUser.CodingKeys.email.rawValue] = email
                }
                if !homeCountry.isEmpty {
                    updateFields[DBUser.CodingKeys.homeCountry.rawValue] = homeCountry
                }
                if !bio.isEmpty {
                    updateFields[DBUser.CodingKeys.bio.rawValue] = bio
                }
                if let image = selectedImage {
                    // Assuming you have a method to upload the image and get the URL
                    let imageURL = try await UserManager.shared.uploadImageToFirebase(image)
                    updateFields[DBUser.CodingKeys.photoURL.rawValue] = imageURL
                }

                if !updateFields.isEmpty {
                    try await UserManager.shared.updateUserInformation(userId: userId, fields: updateFields)
                } else {
                    print("No fields have been edited.")
                }
        
    }
}

struct EditUserProfileView: View {
    
    @StateObject var viewModel = EditUserProfileViewModel()
    var user: DBUser
    @State private var isImagePickerPresented = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
               UserPFPView(user: user)
                
                Button {
                    isImagePickerPresented.toggle()
                } label: {
                    Text("Upload profile picture")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                
                BottomLineTextField(placeholder: "\(user.firstName ?? "First Name")", text: $viewModel.firstName)
                
                BottomLineTextField(placeholder: "\(user.lastName ?? "Last Name")", text: $viewModel.lastName)
                    .padding(.vertical)
                
                BottomLineTextField(placeholder: "\(user.homeCountry ?? "Home Country")", text: $viewModel.homeCountry)
                
                CustomTextEditor(placeholder: "\(user.bio ?? "Your Biography")", text: $viewModel.bio)
                    .padding(.top, 25)
                
                Button {
                    Task {
                        try await viewModel.saveChanges(userId: user.userId)
                        dismiss()
                    }
                } label: {
                    Text("Save Changes")
                        .font(.title3)
                }
                .padding(.top, 20)
                
                Spacer()
                .navigationTitle("Edit Profile")
            }
            .photosPicker(isPresented: $isImagePickerPresented, selection: $viewModel.imageSelection, matching: .images)
            .onChange(of: viewModel.imageSelection) { newSelection in
                Task {
                    if let image = try await viewModel.loadImage(from: newSelection) {
                        viewModel.selectedImage = image
                    }
                }
            }
            .background(.yellow)
        }
    }
}

#Preview {
    EditUserProfileView(user: DBUser(userId: "12345", firstName: "Max", lastName: "Roberts", bio: "Test Biography"))
}
