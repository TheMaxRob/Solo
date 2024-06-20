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
    
    var body: some View {
        ZStack {
            NavigationStack {
                SoloTabView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView, showCreateAccountView: $showCreateAccountView)
            }
        })
    }
}

#Preview {
    RootView()
}
