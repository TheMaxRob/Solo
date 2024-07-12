//
//  SignInEmailView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var isNotAuthenticated: Bool
    @Binding var showSignInView: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color(.gray).opacity(0.4))
                    .cornerRadius(10)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color(.gray).opacity(0.4))
                    .cornerRadius(10)
                
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                            isNotAuthenticated = false
                        } catch {
                            print("Sign in error: \(error)")
                            showAlert = true
                            alertMessage = "Failed to sign in: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                ForgotPasswordButton()
                    .padding()
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In with Email")
        }
    }
}

#Preview {
    SignInEmailView(isNotAuthenticated: .constant(true), showSignInView: .constant(true))
}
