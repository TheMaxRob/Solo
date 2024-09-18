//
//  TravelTabView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

@MainActor
final class SoloTabViewModel: ObservableObject {
    @Published var user: DBUser = DBUser(userId: "")
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
    }
}

struct SoloTabView: View {
    @StateObject private var viewModel = SoloTabViewModel()
    @Binding var isNotAuthenticated: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView(isNotAuthenticated: $isNotAuthenticated)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)
                
                MessagesView()
                    .tabItem { Label("Messages", systemImage: "message.fill") }
                    .tag(1)
                
                ProfileView(isNotAuthenticated: $isNotAuthenticated)
                    .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                    .tag(2)
            }
            .tint(.blue)
            .navigationTitle(tabTitle)
            //.navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task { try await viewModel.loadCurrentUser() }
        }
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0:
            return ""
        case 1:
            return "Messages"
        case 2:
            return ""
        default:
            return ""
        }
    }
}
