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
    @EnvironmentObject private var userStateManager: UserStateManager
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                MapView()
                    .tabItem { Label("Home", systemImage: "globe") }
                    .tag(0)
                
                MessagesView()
                    .tabItem { Label("Messages", systemImage: "message.fill") }
                    .tag(1)
                    .badge(userStateManager.currentUser?.hasUnreadMessages == true ? "" : nil)
                
                ProfileView(isNotAuthenticated: $isNotAuthenticated)
                    .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                    .tag(2)
                    .badge((userStateManager.currentUser?.hasNewRequest ?? false || userStateManager.currentUser?.hasNewAcceptance ?? false) ? "" : nil)
            }
            .background(.clear)
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
