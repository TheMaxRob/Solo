//
//  MeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

@MainActor
final class MeetupsViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser
    
    
    func loadCurrentUser() {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func RSVPMeetup() {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.RSVPMeetup(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        } catch {
            print("Error RSVPing to Meetup!")
        }
    }
}

struct MeetupsView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MeetupsView()
}
