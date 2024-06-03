//
//  MeetupDetailsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

@MainActor
final class MeetupDetailsViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func RSVPMeetup(meetup: Meetup) {
       guard let user else { return }

       Task {
           do {
               try await UserManager.shared.RSVPMeetup(userId: user.userId, meetup: meetup )
               self.user = try await UserManager.shared.getUser(userId: user.userId)
           } catch {
               print("Error RSVPing to Meetup!")
           }
       }
    }
    
    
   
        
        
}
struct MeetupDetailsView: View {
    
    @StateObject var viewModel = MeetupDetailsViewModel()
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Text("\(meetup.title)")
                    .font(.headline)
                    .padding(.bottom)
                
                Text("Meet At: \(meetup.meetSpot)")
                    .font(.subheadline)
                
                Text("\(meetup.meetTime)")
                    .font(.subheadline)
                    .padding(.bottom)
                
                Text("\(meetup.description)")
                    .font(.caption)
                
                HStack {
                    Button {
                        viewModel.RSVPMeetup(meetup: meetup)
                    } label: {
                        Text("RSVP")
                            .frame(width: 90, height: 45)
                            .background(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        // Animate into checkmark, popup to show you requested RSVP
                    }
                    
                    Button {
                        // Send to personal message view with organizer.
                        // How to know user id of organizer?
                    } label: {
                        Text("Message")
                            .tint(.black)
                            .fontWeight(.light)
                            .frame(width: 90, height: 45)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                }
            }
            .navigationTitle("Meetup Details")
            
        }
    }
}

#Preview {
    MeetupDetailsView(meetup: MockMeetups.mockMeetups[0])
}
