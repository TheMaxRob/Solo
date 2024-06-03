//
//  MeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

@MainActor
final class MeetupsViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
//    func RSVPMeetup() {
//        guard let user else { return }
//        
//        Task {
//            do {
//                try await UserManager.shared.RSVPMeetup(meetup: meetup, userId: user.userId)
//                self.user = try await UserManager.shared.getUser(userId: user.userId)
//            } catch {
//                print("Error RSVPing to Meetup!")
//            }
//        }
//    }
}

struct MeetupsView: View {
    
    // MARK: You can only see the location of the event if you are accepted to RSVP by the host
    var body: some View {
        NavigationStack {
            List {
                ForEach(MockMeetups.mockMeetups) { meetup in
                    NavigationLink(destination: MeetupDetailsView(meetup: meetup)) {
                        VStack {
                            MeetupView(meetup: meetup)
                        }
                        
                    }
                }
            }
            .navigationTitle("Meetups")
        }
    }
}


#Preview {
    MeetupsView()
}
