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
    @State private var isErrorAlertPresented = false
    
    
    var body: some View {
        NavigationStack {
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            isNotAuthenticated = true
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }
                }
                
                Button(role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteUser()
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }
                    isNotAuthenticated = true
                } label: {
                    Text("Delete Account")
                }
                emailSection
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
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
        } header: {
            Text("Email Section")
        }
    }
}
