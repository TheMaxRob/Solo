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
                try await UserManager.shared.RSVPMeetup(userId: user.userId, meetup: meetup)
                self.user = try await UserManager.shared.getUser(userId: user.userId)
            } catch {
                print("Error RSVPing to Meetup!")
            }
        }
    }
    
    func createConversation(with organizerId: String) async throws -> String? {
        print("Test output – Above guard let user")
        guard let user else { return nil }
        
        let userIds = [user.userId, organizerId]
        let conversationId = try await MessageManager.shared.createConversation(userIds: userIds)
        print("Test Output – after MessageManager.createConversation")
        print("Conversation created with ID: \(conversationId)")
        return conversationId
    }
}

struct MeetupDetailsView: View {
    @StateObject var viewModel = MeetupDetailsViewModel()
    @State private var isShowingPersonalMessageView = false
    @State private var conversationId: String?
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
                        Task {
                            try await viewModel.loadCurrentUser()
                            conversationId = try await viewModel.createConversation(with: meetup.organizer.userId)
                            isShowingPersonalMessageView = true
                            
                        }
                    } label: {
                        Text("Message")
                            .tint(.black)
                            .fontWeight(.light)
                            .frame(width: 90, height: 45)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                NavigationLink(destination: PersonalMessageView(conversationId: conversationId ?? ""), isActive: $isShowingPersonalMessageView) {
                    EmptyView()
                }
            }
            .navigationTitle("Meetup Details")
        }
    }
}

#Preview {
    MeetupDetailsView(meetup: MockMeetups.mockMeetups[0])
}
