//
//  RequestedMeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/9/24.
//

import SwiftUI


struct RequestedMeetupView: View {
    
    var viewModel: UpcomingMeetupsViewModel
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
