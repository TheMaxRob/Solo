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
    @Published var errorMessage: String? = nil
    
    
    func signIn() async throws -> DBUser? {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return nil
        }
        
        do {
            let authDataResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
            let user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
            return user
        } catch {
            errorMessage = "There was an error fetching your account."
        }
        // try await UserManager.shared.createNewUser(user: user)
//        let user = DBUser(auth: authDataResult)
//        try await UserManager.shared.createNewUser(user: user)
        return nil
    }
    
    
    func changePassword(newPassword: String) async throws {
        guard !newPassword.isEmpty else {
            errorMessage = "Please enter a new password."
            return
        }
        
        do {
            try await AuthenticationManager.shared.updatePassword(newPassword: newPassword)
        } catch {
            print("Error: \(error)")
            errorMessage = "There was an error changing your password."
        }
    }
}
