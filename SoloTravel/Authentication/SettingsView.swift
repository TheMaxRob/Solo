//
//  SettingsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    
    func updateEmail() async throws {
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(newEmail: email)
    }
    
    
    func updatePassword() async throws {
        let password = "Hello123!"
        try await AuthenticationManager.shared.updatePassword(newPassword: password)
    }
    
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
    
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        NavigationStack {
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                        
                    }
                }
                
                Button(role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteUser()
                            print("USER DELETED")
                        } catch {
                            print(error)
                        }
                    }
                    
                    showSignInView = true
                } label: {
                    Text("Delete Account")
                }
                
                emailSection
                
                
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(showSignInView: .constant(false))
}


extension SettingsView {
    
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET")
                    } catch {
                        print(error)
                    }
                }
                
            }
            
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED")
                    } catch {
                        print(error)
                    }
                }
                
            }
        } header: {
            Text("Email Section")
        }
    }
}
