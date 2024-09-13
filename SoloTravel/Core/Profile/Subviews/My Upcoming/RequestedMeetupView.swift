//
//  RequestedMeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/9/24.
//

import SwiftUI


struct RequestedMeetupView: View {
    
    @ObservedObject var viewModel: UpcomingMeetupsViewModel
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                NavigationLink {
                    PublicProfileView(userId: viewModel.host.userId)
                } label: {
                    if let image = viewModel.profileImage {
                        UserPFPView(user: viewModel.host)
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
                    } else {
                        ProgressView()  // Show loading indicator until the image is fetched
                            .frame(width: 50, height: 50)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(meetup.title)
                        .font(.headline)
                    Text(formatDayAndTime(date: meetup.meetTime ?? Date()))
                        .font(.subheadline)
                }
            }
            .padding()
            .frame(width: 400)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .shadow(radius: 10, x: 3, y: 5)
            .onAppear {
                Task {
                    do {
                        // Fetch host and image on appear
                        try await viewModel.getHost(userId: meetup.organizerId ?? "Unknown")
                        if let url = viewModel.host.photoURL {
                            try await viewModel.loadImage(from: url)
                        }
                    } catch {
                        print("Error loading host or image: \(error)")
                    }
                }
            }
            .overlay(Button {
                Task {
                    do {
                        try await viewModel.unRequest(meetupId: meetup.id, userId: viewModel.user?.userId ?? "")
                    } catch {
                        print("Error un-requesting meetup: \(error)")
                    }
                }
            } label: {
                Image(systemName: "door.left.hand.open")
                    .foregroundStyle(.red)
            }
            .padding(), alignment: .topTrailing)
        }
    }
    
    private func formatDayAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

