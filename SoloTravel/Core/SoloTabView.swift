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
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct SoloTabView: View {
    
    @StateObject private var viewModel = SoloTabViewModel()
    @Binding var isNotAuthenticated: Bool
    
    var body: some View {
        TabView {
            HomeView(isNotAuthenticated: $isNotAuthenticated)
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill") 
                }
                .badge(viewModel.user.hasUnreadMessages ?? false ? "" : nil)
            
            ProfileView(isNotAuthenticated: $isNotAuthenticated)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .badge(viewModel.user.hasNewRequest ?? false || viewModel.user.hasNewAcceptance ?? false ? "" : nil)
        }
        .tint(.blue)
        .onAppear {
            Task { try await viewModel.loadCurrentUser() }
        }
    }
}

#Preview {
    SoloTabView(isNotAuthenticated: .constant(false))
}
