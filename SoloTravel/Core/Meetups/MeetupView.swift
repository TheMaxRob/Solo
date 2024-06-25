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
    @Published private(set) var host: DBUser? = nil
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
}

struct MeetupView: View {
    
    @StateObject var viewModel = MeetupViewModel()
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 80))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
                }
                VStack {
                    Text("\(String(describing: meetup.title))")
                        .font(.headline)
                    Text("\(formatDayAndTime(date: meetup.meetTime))")
                    
                }
            }
            .onAppear {
                Task {
                    try await viewModel.getHost(userId: meetup.organizerId)
                    try await viewModel.loadImage(from: viewModel.host?.photoURL ?? "")
                }
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
    MeetupView(meetup: Meetup(id: "id", title: "Title", description: "description", meetTime: Date(), city: "Paris", createdDate: Date(), organizerId: "organizerId", meetSpot: "Spot"))
}
