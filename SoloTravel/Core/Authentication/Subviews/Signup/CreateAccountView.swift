//
//  CreateAccountView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import SwiftUI


struct CreateAccountView: View {
    
    @StateObject private var viewModel = CreateAccountViewModel()
    @Binding var showCreateAccountView: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State var isShowingProfileCreationView: Bool = false
    @Binding var isNotAuthenticated: Bool
    @State private var isErrorAlertPresented = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 17) {
                TextField("Email", text: $viewModel.email)
                    .padding(13)
                    .background(Color(.gray).opacity(0.4))
                    .cornerRadius(10)
                
                SecureField("Password", text: $viewModel.password)
                    .padding(13)
                    .background(Color(.gray).opacity(0.4))
                    .cornerRadius(10)
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signUp()
                            isShowingProfileCreationView = true
                        } catch {
                            showAlert = true
                            alertMessage = "Failed to sign in: \(error.localizedDescription)"
                        }
                    }
                }, label: {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .navigationTitle("Create Your Account")
                Spacer()
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .padding()
            .fullScreenCover(isPresented: $isShowingProfileCreationView, content: {
                ProfileCreationView(isShowingProfileCreationView: $isShowingProfileCreationView,
                                    isShowingAccountCreationView: $showCreateAccountView,
                                    isNotAuthenticated: $isNotAuthenticated)
            })
        }
    }
}

#Preview {
    CreateAccountView(showCreateAccountView: .constant(true), isNotAuthenticated: .constant(true))
}
