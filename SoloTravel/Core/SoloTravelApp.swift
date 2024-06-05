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
    
    init() {
        FirebaseApp.configure()
        print("Configured Firebase")
    }
    var body: some Scene {
        WindowGroup {
                RootView()
        }
    }
}
