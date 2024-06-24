//
//  SignInEmailViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Max Roberts on 5/3/24.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.") // Should do some real validation in real app
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
        // try await UserManager.shared.createNewUser(user: user)
//        let user = DBUser(auth: authDataResult)
//        try await UserManager.shared.createNewUser(user: user)
    }
    
    
    func changePassword(newPassword: String) async throws {
        guard !newPassword.isEmpty else {
            print("Please enter a new password.")
            return
        }
        
        try await AuthenticationManager.shared.updatePassword(newPassword: newPassword)
    }
}
