//
//  TravelTabView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct SoloTabView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            HomeView(showSignInView: $showSignInView)
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            
        }
        .tint(.blue)
    }
}

#Preview {
    SoloTabView(showSignInView: .constant(false))
}
