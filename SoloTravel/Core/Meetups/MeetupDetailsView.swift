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
    @Published var conversationId: String?
    @Published var host: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func requestRSVP(meetup: Meetup) {
        guard let user else {
            print("No user found.")
            return
        }
        Task {
            do {
                try await UserManager.shared.requestRSVP(userId: user.userId, meetupId: meetup.id)
                
            } catch {
                print("Error RSVPing to Meetup!")
            }
        }
    }
    
    
    func createConversation(with organizerId: String) async throws -> String? {
        guard let user else { return nil }
        
        let userIds = [user.userId, organizerId]
        let conversationId = try await MessageManager.shared.createConversation(userIds: userIds)
        return conversationId
    }
    
    
    func getHost(userId: String) async throws {
        host = try await UserManager.shared.getUser(userId: userId)
    }
    
}

struct MeetupDetailsView: View {
    @StateObject var viewModel = MeetupDetailsViewModel()
    @State private var isShowingPersonalMessageView = false
    
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(meetup.title)")
                    .font(.headline)
                    .padding(.bottom)
                    .frame(width: 400)
                
                Text("Host: \(viewModel.host?.firstName ?? "Unknown") \(viewModel.host?.lastName ?? "")")
                
                Text("Meet At: \(meetup.meetSpot ?? "")")
                    .font(.subheadline)
                
                Text("\(meetup.meetTime ?? Date())")
                    .font(.subheadline)
                    .padding(.bottom)
                
                Text("\(String(describing: meetup.description))")
                    .font(.caption)
                
                HStack {
                    Button {
                        Task {
                            try await viewModel.loadCurrentUser()
                            viewModel.requestRSVP(meetup: meetup)
                        }
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
                            viewModel.conversationId = try await viewModel.createConversation(with: meetup.organizerId ?? "")
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
                .navigationDestination(isPresented: $isShowingPersonalMessageView) {
                    ChatView(conversationId: viewModel.conversationId ?? "")
                }
                Spacer()
            }
            .onAppear {
                Task {
                    try await viewModel.getHost(userId: meetup.organizerId ?? "")
                }
            }
            .background(.yellow)
            .navigationTitle("Meetup Details")
        }
    }
}
