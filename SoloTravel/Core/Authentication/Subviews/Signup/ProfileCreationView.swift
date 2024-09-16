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
    
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack {
                    Text("Welcome!")
                        .bold()
                        .font(.title)
                    
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .shadow(radius: 5)
                            .onTapGesture {
                                isImagePickerPresented.toggle()
                            }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: 400, height: 400)
                                .foregroundStyle(Color(red: 0.95, green: 0.95, blue: 0.95))
                            
                            VStack {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 75))
                                    .foregroundStyle(.gray)
                                
                                Text("Upload a picture for your meetup!")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                        .padding(.bottom)
                    }
                    
                    BottomLineTextField(placeholder: "First Name", text: $viewModel.firstName)
                    BottomLineTextField(placeholder: "Last Name", text: $viewModel.lastName)
                    BottomLineTextField(placeholder: "Home Country", text: $viewModel.homeCountry)
                    BottomLineTextField(placeholder: "How old are you?", text: $viewModel.age)
                        .padding(.top, 10)
                    
                    CustomTextEditor(placeholder: "Tell us about yourself!", text: $viewModel.bio)
                    // Make it so there's a word limit on the biography
                    
                    NavigationLink {
                        WelcomeView(isNotAuthenticated: $isNotAuthenticated, isShowingWelcomeView: $viewModel.isShowingWelcomeView)
                    } label: {
                        Text("Save and Continue")
                            .padding()
                            .frame(width: 350)
                            .background(.black)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        // .foregroundStyle(.yellow)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            do {
                                try await viewModel.loadCurrentUser()
                                try await viewModel.saveUserProfile()
                            } catch {
                                showErrorAlert = true
                            }
                        }
                    })
                    Spacer()
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Something went wrong"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .photosPicker(isPresented: $isImagePickerPresented, selection: $viewModel.imageSelection, matching: .images)
            .onChange(of: viewModel.imageSelection) { _, newSelection in
                Task {
                    if let image = try await viewModel.loadImage(from: newSelection) {
                        viewModel.selectedImage = image
                    }
                }
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
