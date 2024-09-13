//
//  MeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

@MainActor
final class MeetupViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var host: DBUser = DBUser(userId: "")
    @Published var profileImage: UIImage? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func getHost(userId: String) async throws {
            host = try await UserManager.shared.getUser(userId: userId)
            // Load image after host is set
            if let photoURL = host.photoURL, !photoURL.isEmpty {
                try await loadImage(from: photoURL)
            }
        }
        
        func loadImage(from url: String) async throws {
            profileImage = try await UserManager.shared.loadImage(from: url)
            print("loaded Image")
        }
}


struct MeetupView: View {
    
    @StateObject var viewModel = MeetupViewModel()
    var meetup: Meetup
    
    var body: some View {
        HStack {
            // Show profile image when loaded
            if let profileImage = viewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            } else {
                UserPFPView(user: viewModel.host)
            }
            
            Spacer()
            
            VStack {
                Text(meetup.title)
                    .font(.headline)
                Text(formatDayAndTime(date: meetup.meetTime ?? Date()))
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .frame(width: 350)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 10, x: 3, y: 5)
        .onAppear {
            Task {
                try await viewModel.getHost(userId: meetup.organizerId ?? "Unknown")
            }
        }
    }
    
    private func formatDayAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    MeetupView(meetup: Meetup(title: "Title", description: "description", meetTime: Date(), city: "Paris", country: "France", createdDate: Date(), organizerId: "organizerId", meetSpot: "Spot", attendees: [], pendingUsers: [], imageURL: ""))
}
