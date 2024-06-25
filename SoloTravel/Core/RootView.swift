//
//  RootView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

struct RootView: View {
    @State var showSignInView: Bool = false
    @State var showCreateAccountView: Bool = false
    @State var isNotAuthenticated: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                SoloTabView(isNotAuthenticated: $isNotAuthenticated)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.isNotAuthenticated = authUser == nil
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
