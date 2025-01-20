//
//  SoloTravelApp.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI
import Firebase

@main
struct SoloTravelApp: App {
    @StateObject private var userStateManager = UserStateManager()
    
    init() {
        FirebaseApp.configure()
        print("Configured Firebase")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userStateManager)
            //MapView()
        }
    }
}
