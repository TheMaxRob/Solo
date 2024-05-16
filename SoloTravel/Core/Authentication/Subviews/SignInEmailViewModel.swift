//
//  SignInEmailViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/5/24.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.") // Should do some real validation in real app
            return
        }
        
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.") // Should do some real validation in real app
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    
    func changePassword(newPassword: String) async throws {
        guard !newPassword.isEmpty else {
            print("Please enter a new password.")
            return
        }
        
        try await AuthenticationManager.shared.updatePassword(newPassword: newPassword)
    }
}
