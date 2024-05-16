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
    
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
      }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
        }
    }
}
