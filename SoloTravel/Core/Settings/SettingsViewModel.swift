//
//  SettingsViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/1/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    
    func signOut() throws {
        do {
            try AuthenticationManager.shared.signOut()
        } catch {
            errorMessage = "There was an error signing you out."
        }
    }
    
    
    func resetPassword() async throws {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            guard let email = authUser.email else {
                throw URLError(.fileDoesNotExist)
            }
            try await AuthenticationManager.shared.resetPassword(email: email)
        } catch {
            errorMessage = "There was an error resetting your password."
        }
    }
    
    
    func updateEmail() async throws {
        do {
            let email = "hello123@gmail.com"
            try await AuthenticationManager.shared.updateEmail(newEmail: email)
        } catch {
            errorMessage = "There was an error updating your email."
        }
    }    
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
    
}

