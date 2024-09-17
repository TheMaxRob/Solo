//
//  UpcomingMeetupView.swift
//  SoloTravel
//
//  Created by/Users/themaxroberts/Desktop/CS Projects/Solo/SoloTravel/Core/Profile/Subviews/My Upcoming/RequestedMeetupView.swift Max Roberts on 7/9/24.
//

import SwiftUI


struct UpcomingMeetupView: View {
    
    var viewModel: UpcomingMeetupsViewModel
    var meetup: Meetup
    var hostId: String
    @State private var isErrorAlertPresented = false
    @State private var isUnRSVPAlertPresented = false
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                NavigationLink {
                    PublicProfileView(userId: hostId)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10, x: 3, y: 5)
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadCurrentUser()
                        try await viewModel.getHost(userId: meetup.organizerId ?? "Unknown")
                        try await viewModel.loadImage(from: viewModel.host.photoURL ?? "")
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
            .overlay(Button {
                Task {
                    isUnRSVPAlertPresented = true
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
            }.padding(), alignment: .topTrailing)
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $isUnRSVPAlertPresented, content: {
                Alert(title: Text("Remove RSVP"), message: Text("Are you sure you want unRSVP from this meetup?"), primaryButton: .destructive(Text("Confirm")) {
                    Task {
                        do {
                            try await viewModel.unRSVP(meetupId: meetup.id, userId: viewModel.user?.userId ?? "")
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }
                }, secondaryButton: .cancel())
            })

        }
        
    }
    
    private func formatDayAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        return formatter.string(from: date)
    }
}
