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
    @Binding var isShowingSignInView: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome!")
                    .bold()
                .font(.title)
                Button {
                    // Bring up a picture selection screen
                } label: {
                    Text("Tell us a little about yourself to get started.")
                        .foregroundStyle(.black.opacity(0.6))
                        .font(.subheadline)
                }
                
                
                Spacer()
                    .frame(height: 15)
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 85))
                Text("Upload profile picture")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                VStack(alignment: .leading, spacing: 18) {
                    BottomLineTextField(placeholder: "First Name", text: $vm.firstName)
                    BottomLineTextField(placeholder: "Last Name", text: $vm.lastName)
                    BottomLineTextField(placeholder: "Home Country", text: $vm.homeCountry)
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(" Date of Birth")
                                .foregroundStyle(.gray.opacity(0.8))
                                .padding(.horizontal)
                                
                            Spacer()
                        }
                        
                       
                        HStack {
                            DatePicker("", selection: $vm.birthDate, displayedComponents: .date )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                                .tint(.black.opacity(0.4))
                                .foregroundStyle(.gray.opacity(0.7))
                                .padding(.horizontal)
                            Spacer()
                        }
                           
                    }
                    .padding(.top, 10)
                    
                    TextEditor(text: $vm.bio)
                        .foregroundStyle(.black.opacity(0.5))
                        .cornerRadius(10)
                        .frame(height: 225)
                        .scrollContentBackground(.hidden)
                        .background(Color(red: 0.8, green: 0.6, blue: 0.0))
                        .padding(.horizontal)
                        .padding(.bottom)
                        // Make it so there's a word limit on the biography
                }
                
                Button {
                    Task {
                        do {
                            try await vm.loadCurrentUser()
                            try await vm.saveUserProfile()
                            isShowingProfileCreationView = false
                            isShowingSignInView = false
                            isShowingAccountCreationView = false
                        } catch {
                            print("Error saving user profile.")
                        }
                    }
                } label: {
                    Text("Save and Continue")
                        .padding()
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .foregroundStyle(.yellow)
                        
                        
                    
                }
                Spacer()
            }
            .background(.yellow)
        }
    }
}

#Preview {
    ProfileCreationView(isShowingProfileCreationView: .constant(true), isShowingAccountCreationView: .constant(true), isShowingSignInView: .constant(true))
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
                }
            )
    }
}
