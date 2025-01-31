//
//  ProfileCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import SwiftUI

struct ProfileCreationView: View {
    
    @StateObject var viewModel = ProfileCreationViewModel()
    @Binding var isShowingProfileCreationView: Bool
    @Binding var isShowingAccountCreationView: Bool
    @Binding var isNotAuthenticated: Bool
    @State private var isImagePickerPresented = false
    @State private var showErrorAlert = false
    @EnvironmentObject var userStateManager: UserStateManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Welcome!")
                        .bold()
                        .font(.title)
                    
                    // Profile Picture
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                            .onTapGesture {
                                isImagePickerPresented.toggle()
                            }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: 200, height: 200)
                                .foregroundStyle(Color(red: 0.95, green: 0.95, blue: 0.95))
                            
                            VStack {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.gray)
                                
                                Text("Upload a picture for your profile!")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                    }
                    
                    // Text Fields
                    BottomLineTextField(placeholder: "First Name", text: $viewModel.firstName)
                    BottomLineTextField(placeholder: "Last Name", text: $viewModel.lastName)
                    BottomLineTextField(placeholder: "Home Country", text: $viewModel.homeCountry)
                    
                    
                    HStack(spacing: 12) {
                        ForEach(AgeRange.allCases, id: \.self) { range in
                            Button {
                                // When tapped, set the selected age range
                                viewModel.selectedAgeRange = range
                            } label: {
                                Text(range.rawValue)
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

                    
                    
                    // Biography
                    CustomTextEditor(placeholder: "Tell us about yourself!", text: $viewModel.bio)
                        .frame(height: 120)
                        .padding(.bottom, 20)
                    
                    // Interests Section
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
                    
                    // Save and Continue Button
                    NavigationLink {
                        WelcomeView(isNotAuthenticated: $isNotAuthenticated, isShowingWelcomeView: $viewModel.isShowingWelcomeView)
                    } label: {
                        Text("Save and Continue")
                            .padding()
                            .frame(width: 350)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            do {
                                try await userStateManager.loadUser()
                                try await viewModel.saveUserProfile(userId: userStateManager.currentUser?.userId ?? "")
                            } catch {
                                showErrorAlert = true
                            }
                        }
                    })
                    
                    Spacer()
                }
                .padding()
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Something went wrong"),
                    dismissButton: .default(Text("OK"))
                )
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
        }
    }
    
    func interestTagView(for tag: Tag) -> some View {
        Text(tag.rawValue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(viewModel.selectedTags.contains(tag) ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundColor(viewModel.selectedTags.contains(tag) ? .green : .gray)
            .font(.footnote)
            .clipShape(Capsule())
            .onTapGesture {
                if viewModel.selectedTags.contains(tag) {
                    viewModel.selectedTags.remove(tag)
                } else {
                    viewModel.selectedTags.insert(tag)
                }
            }
    }
}


#Preview {
    ProfileCreationView(isShowingProfileCreationView: .constant(true), isShowingAccountCreationView: .constant(true), isNotAuthenticated: .constant(true))
}


struct BottomLineTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal)
                })
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0)
    }
}



struct CustomTextEditor: View {
    var placeholder: String
    @Binding var text: String
    var body: some View {
        TextEditor(text: $text)
            .foregroundStyle(.black.opacity(0.5))
            .frame(height: 300)
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom)
    }
}
