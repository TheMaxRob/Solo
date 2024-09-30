//
//  RootView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject private var userStateManager: UserStateManager
    @State var isNotAuthenticated: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                SoloTabView(isNotAuthenticated: $isNotAuthenticated, user: userStateManager.currentUser ?? DBUser(userId: ""))
            }
        }
        .onAppear {
            Task { try await userStateManager.loadUser() }
        }
        .onChange(of: userStateManager.currentUser) { _, newUser in
            isNotAuthenticated = newUser == nil
            Task {
                try await userStateManager.refreshUser()
            }
        }
        .fullScreenCover(isPresented: $isNotAuthenticated, content: {
            NavigationStack {
                AuthenticationView(showAuthenticationView: $isNotAuthenticated, isNotAuthenticated: $isNotAuthenticated)
            }
        })
    }
}

#Preview {
    RootView()
}
