//
//  SettingsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var isNotAuthenticated: Bool
    
    
    var body: some View {
        NavigationStack {
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            isNotAuthenticated = true
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
                    isNotAuthenticated = true
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
    SettingsView(isNotAuthenticated: .constant(false))
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
