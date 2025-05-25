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
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var homeCountry: String = ""
    var bio: String = ""
    
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    @Published var errorMessage: String? = nil
    @Published var selectedInterests: Set<Tag> = []
    @Published var selectedAgeRange: AgeRange? = nil
    
    @Published var facebookUsername: String = ""
    @Published var instagramUsername: String = ""


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
        if let selectedAgeRange = selectedAgeRange {
            updateFields[DBUser.CodingKeys.ageRange.rawValue] = selectedAgeRange.rawValue
        }
        
        let updatedSocials: [String: String] = [
            "facebook": facebookUsername,
            "instagram": instagramUsername
        ]
        updateFields[DBUser.CodingKeys.socials.rawValue] = updatedSocials
        
        let interestsArray = selectedInterests.map(\.rawValue)
        updateFields[DBUser.CodingKeys.interests.rawValue] = interestsArray
        
        if let image = selectedImage {
            let imageURL = try await UserManager.shared.uploadImageToFirebase(image, userId: userId)
            updateFields[DBUser.CodingKeys.photoURL.rawValue] = imageURL
        }
        
        if !updateFields.isEmpty {
            do {
                try await UserManager.shared.updateUserInformation(userId: userId, fields: updateFields)
            } catch {
                errorMessage = "There was a problem saving your new profile information. Please try again later."
            }
        } else {
            errorMessage = "Please edit a field to save your new profile information."
        }
    }
    
    func setBio(bio: String) {
        self.bio = bio
    }
}


struct EditUserProfileView: View {
    
    @StateObject var viewModel = EditUserProfileViewModel()
    @EnvironmentObject var userStateManager: UserStateManager
    
    @State private var isImagePickerPresented = false
    @State private var isErrorAlertPresented = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: - Profile Image
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 85))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }
                    
                    Button {
                        isImagePickerPresented.toggle()
                    } label: {
                        Text("Upload profile picture")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    // MARK: - Text Fields
                    BottomLineTextField(
                        placeholder: "\(userStateManager.currentUser?.firstName ?? "First Name")",
                        text: $viewModel.firstName
                    )
                    
                    BottomLineTextField(
                        placeholder: "\(userStateManager.currentUser?.lastName ?? "Last Name")",
                        text: $viewModel.lastName
                    )
                    
                    BottomLineTextField(
                        placeholder: "\(userStateManager.currentUser?.homeCountry ?? "Home Country")",
                        text: $viewModel.homeCountry
                    )
                    
                    // MARK: - Age Range Selection
                    Text("Select Your Age Range")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(AgeRange.allCases, id: \.self) { range in
                            Button {
                                viewModel.selectedAgeRange = range
                            } label: {
                                Text(range.rawValue)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.selectedAgeRange == range
                                        ? Color.blue.opacity(0.2)
                                        : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        viewModel.selectedAgeRange == range
                                        ? .blue
                                        : .gray
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // MARK: - Biography
                    CustomTextEditor(
                        placeholder: "\(userStateManager.currentUser?.bio ?? "Your Biography")",
                        text: $viewModel.bio
                    )
                    .frame(minHeight: 120)
                    .padding(.bottom, 20)
                    
                    // MARK: - Interests Selection
                    Text("Select Your Interests")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(Tag.allCases, id: \.self) { tag in
                                interestTagView(for: tag)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 200)
                    
                    
                    // MARK: - Social Fields
                    Text("Social Links (Optional)")
                        .font(.headline)
                    // Facebook
                    BottomLineTextField(
                        placeholder: "Facebook Username",
                        text: $viewModel.facebookUsername
                    )
                    // Instagram
                    BottomLineTextField(
                        placeholder: "Instagram Username",
                        text: $viewModel.instagramUsername
                    )
                    
                    Button {
                        Task {
                            do {
                                try await viewModel.saveChanges(userId: userStateManager.currentUser?.userId ?? "")
                                try await userStateManager.refreshUser()
                                dismiss()
                            } catch {
                                isErrorAlertPresented = true
                            }
                        }
                    } label: {
                        Text("Save Changes")
                            .font(.title3)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                if let user = userStateManager.currentUser {
                    viewModel.firstName = user.firstName ?? ""
                    viewModel.lastName = user.lastName ?? ""
                    viewModel.homeCountry = user.homeCountry ?? ""
                    viewModel.bio = user.bio ?? ""
                    
                    // Load the user's age range if available.
                    if let ageRangeString = user.ageRange?.rawValue,
                       let ageRange = AgeRange(rawValue: ageRangeString) {
                        viewModel.selectedAgeRange = ageRange
                    }
                    
                    if let existingInterests = user.interests {
                        viewModel.selectedInterests = Set(existingInterests)
                    }
                    
                    if let userSocials = user.socials {
                                            viewModel.facebookUsername = userSocials["facebook"] ?? ""
                                            viewModel.instagramUsername = userSocials["instagram"] ?? ""
                                        }
                }
            }
            .photosPicker(
                isPresented: $isImagePickerPresented,
                selection: $viewModel.imageSelection,
                matching: .images
            )
            .onChange(of: viewModel.imageSelection) { _, newSelection in
                Task {
                    if let image = try await viewModel.loadImage(from: newSelection) {
                        viewModel.selectedImage = image
                    }
                }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Something went wrong."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func interestTagView(for tag: Tag) -> some View {
            Text(tag.rawValue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(viewModel.selectedInterests.contains(tag) ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .foregroundColor(viewModel.selectedInterests.contains(tag) ? .green : .gray)
                .font(.footnote)
                .clipShape(Capsule())
                .onTapGesture {
                    if viewModel.selectedInterests.contains(tag) {
                        viewModel.selectedInterests.remove(tag)
                    } else {
                        viewModel.selectedInterests.insert(tag)
                    }
                }
        }
}
