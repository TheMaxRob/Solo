//
//  ProfileView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/5/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AuthDataResultModel? = nil
    
    func loadCurrentUser() throws {
        self.user = try AuthenticationManager.shared.getAuthenticatedUser()
    }
}

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
   
    var body: some View {
        NavigationStack {
            List {
                if let user = viewModel.user {
                    Text("User ID: \(user.uid)")
                }
            }
            .onAppear {
                try? viewModel.loadCurrentUser()
            }
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(showSignInView: $showSignInView)
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                }
            })
        }
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))
}
