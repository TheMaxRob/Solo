//
//  RequestedMeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/9/24.
//

import SwiftUI

@MainActor
final class RequestedMeetupViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var host: DBUser = DBUser(userId: "")
    @Published var profileImage: UIImage? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func getHost(userId: String) async throws {
        host = try await UserManager.shared.getUser(userId: userId)
    }
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func unRequest(meetupId: String, userId: String) async throws {
        try await MeetupManager.shared.unRequest(meetupId: meetupId, userId: userId)
    }
}


struct RequestedMeetupView: View {
    
    @StateObject var viewModel = RequestedMeetupViewModel()
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                NavigationLink {
                    PublicProfileView(userId: viewModel.user?.userId ?? "")
                } label: {
                    UserPFPView(user: viewModel.host)
                }
                
                VStack {
                    Text("\(String(describing: meetup.title))")
                        .font(.headline)
                    Text("\(formatDayAndTime(date: meetup.meetTime ?? Date()))")
                    
                }
            }
            
            .padding()
            .frame(width: 400)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10, x: 3, y: 5)
            .onAppear {
                Task {
                    try await viewModel.getHost(userId: meetup.organizerId ?? "Unknown")
                    try await viewModel.loadImage(from: viewModel.host.photoURL ?? "")
                }
            }
            .overlay(Button {
                Task {
                    try await viewModel.loadCurrentUser()
                    try await viewModel.unRequest(meetupId: meetup.id, userId: viewModel.user?.userId ?? "")
                }
            } label: {
                Image(systemName: "door.left.hand.open")
                    .foregroundStyle(.red)
            }.padding(), alignment: .topTrailing)
        }
        
    }
    
    private func formatDayAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        return formatter.string(from: date)
    }
    
    
    
}

#Preview {
    RequestedMeetupView(meetup: Meetup(title: "Title", description: "description", meetTime: Date(), city: "Paris", country: "France", createdDate: Date(), organizerId: "organizerId", meetSpot: "Spot", attendees: [], pendingUsers: []))
}
