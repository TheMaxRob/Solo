//
//  AuthenticationManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    @Binding var showCreateAccountView: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView)
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
                    CreateAccountView(showCreateAccountView: $showCreateAccountView, showSignInView: $showSignInView)
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
    AuthenticationView(showSignInView: .constant(false), showCreateAccountView: .constant(false))
}
