//
//  ProfileCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import SwiftUI

struct ProfileCreationView: View {
    
    @StateObject var vm = ProfileCreationViewModel()
    @Binding var isShowingProfileCreationView: Bool
    @Binding var isShowingAccountCreationView: Bool
    @Binding var isNotAuthenticated: Bool
    @State private var isImagePickerPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome!")
                    .bold()
                .font(.title)
                
                Spacer()
                    .frame(height: 15)
                if let selectedImage = vm.selectedImage {
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
                
                VStack(alignment: .leading, spacing: 18) {
                    BottomLineTextField(placeholder: "First Name", text: $vm.firstName)
                    BottomLineTextField(placeholder: "Last Name", text: $vm.lastName)
                    BottomLineTextField(placeholder: "Home Country", text: $vm.homeCountry)
                    BottomLineTextField(placeholder: "How old are you?", text: $vm.age)
                    .padding(.top, 10)
                    
                    CustomTextEditor(placeholder: "Tell us about yourself!", text: $vm.bio)
                        // Make it so there's a word limit on the biography
                }
                
                NavigationLink {
                    WelcomeView(isNotAuthenticated: $isNotAuthenticated, isShowingWelcomeView: $vm.isShowingWelcomeView)                
                } label: {
                    Text("Save and Continue")
                        .padding()
                        .frame(width: 350)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.yellow)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Task {
                        print("Task Entered")
                        do {
                            try await vm.loadCurrentUser()
                            print("User loaded")
                            try await vm.saveUserProfile()
                            print("UserProfile saved")
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                })
                Spacer()
            }
            .photosPicker(isPresented: $isImagePickerPresented, selection: $vm.imageSelection, matching: .images)
            .onChange(of: vm.imageSelection) { newSelection in
                Task {
                    if let image = try await vm.loadImage(from: newSelection) {
                        vm.selectedImage = image
                    }
                }
            }
            .background(.yellow)
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
            .cornerRadius(10)
            .frame(height: 225)
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.8, green: 0.6, blue: 0.0))
            .padding(.horizontal)
            .padding(.bottom)
    }
}
