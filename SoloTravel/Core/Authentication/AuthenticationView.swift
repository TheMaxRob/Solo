//
//  AuthenticationManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var showSignInView: Bool = false
    @Published var showCreateAccountView: Bool = false
    
}

struct AuthenticationView: View {
    
    @Binding var showAuthenticationView: Bool
    @StateObject var viewModel = AuthenticationViewModel()
    @Binding var isNotAuthenticated: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                
                NavigationLink {
                    SignInEmailView(showSignInView: $viewModel.showSignInView)
                } label: {
                    Text("Sign in with Email")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink {
                    CreateAccountView( showCreateAccountView: $viewModel.showCreateAccountView, isNotAuthenticated: $isNotAuthenticated)
                } label: {
                    Text("Create Account")
                        .font(.headline)
                        .padding()
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In")
        }
        
        
    }
}

#Preview {
    AuthenticationView(showAuthenticationView: .constant(true), isNotAuthenticated: .constant(true))
}
