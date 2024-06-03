//
//  MeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

struct Meetup: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let meetTime: Date
    let createdDate: Date
    let organizer: DBUser
    let meetSpot: String
}

final class MeetupViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        
    }
    
    
//    func RSVPMeetup(meetup: Meetup) {
//       guard let user else { return }
//
//       Task {
//           do {
//               try await UserManager.shared.RSVPMeetup(meetup: meetup, userId: user.userId)
//               self.user = try await UserManager.shared.getUser(userId: user.userId)
//           } catch {
//               print("Error RSVPing to Meetup!")
//           }
//       }
//   }
        
        
}

struct MeetupView: View {
    
    @StateObject var viewModel = MeetupViewModel()
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(meetup.description)")
                    .font(.caption)
                Text("\(meetup.meetSpot)")
                Text("\(meetup.meetTime)")
                Text("\(meetup.organizer.email ?? "")") // Should be their name but having trouble with that
            }
            .navigationTitle("meetup.title")
        }
        
    }
}

#Preview {
    MeetupView(meetup: MockMeetups.mockMeetups[0])
}
