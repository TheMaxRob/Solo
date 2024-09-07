//
//  TravelTabView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct SoloTabView: View {
    
    @Binding var isNotAuthenticated: Bool
    
    var body: some View {
        TabView {
            HomeView(isNotAuthenticated: $isNotAuthenticated)
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
            ProfileView(isNotAuthenticated: $isNotAuthenticated)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            
        }
        .tint(.blue)
    }
}

#Preview {
    SoloTabView(isNotAuthenticated: .constant(false))
}
