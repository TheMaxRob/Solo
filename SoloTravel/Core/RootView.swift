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
    @State private var isNotAuthenticated: Bool = false
    
    var body: some View {
        Group {
            if isNotAuthenticated {
                NavigationStack {
                    AuthenticationView(showAuthenticationView: $isNotAuthenticated,
                                       isNotAuthenticated: $isNotAuthenticated)
                }
            } else {
                NavigationStack {
                    SoloTabView(isNotAuthenticated: $isNotAuthenticated)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await userStateManager.loadUser()
                } catch {
                    print("Error loading user: \(error)")
                }
                isNotAuthenticated = userStateManager.currentUser == nil
            }
        }
        .onChange(of: userStateManager.currentUser) { oldUser, newUser in
            isNotAuthenticated = (newUser == nil)
        }
    }
}

#Preview {
    RootView()
}
