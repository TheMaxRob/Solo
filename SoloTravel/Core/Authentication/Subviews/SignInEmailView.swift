//
//  SignInEmailView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI


struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email...", text: $viewModel.email)
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
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            print(error)
                        }
                        
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                        
                    }
                    
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In with Email")
        }
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(true))
}
