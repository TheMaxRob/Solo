//
//  TravelTabView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct SoloTabView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            MessagesView()
                .tabItem { Label("Hello", systemImage: "message") }
            
            AccountView()
                .tabItem { Label("Account", systemImage: "person") }
        }
        .tint(.blue)
    }
}

#Preview {
    SoloTabView()
}
