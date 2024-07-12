//
//  MyMeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

@MainActor
final class MyMeetupViewModel: ObservableObject {
    @Published var isShowingAttendeesView = true
    @Published var isShowingPendingView = false
    @Published var pendingUsers: [DBUser] = []
    @Published var attendees: [DBUser] = []
    
    func loadPendingUsers(userIds: [String]) async throws {
        if userIds.isEmpty { return }
        for userId in userIds {
            try await pendingUsers.append(UserManager.shared.getUser(userId: userId))
        }
    }
    
    func loadAttendees(userIds: [String]) async throws {
        if userIds.isEmpty { return }
        for userId in userIds {
            try await attendees.append(UserManager.shared.getUser(userId: userId))
        }
    }
}

struct MyMeetupView: View {
    
    var meetup: Meetup
    @StateObject var viewModel = MyMeetupViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Toggle Buttons
                HStack(spacing: 0) {
                    Button(action: {
                        viewModel.isShowingAttendeesView = true
                        viewModel.isShowingPendingView = false
                    }) {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10)
                                .frame(width: 155, height: 30)
                                .foregroundStyle(viewModel.isShowingAttendeesView ? .gray.opacity(0.7) : .gray.opacity(0.4))
                            Text("Accepted")
                                .foregroundStyle(viewModel.isShowingAttendeesView ? .black : .gray)
                        }
                    }
                    Button {
                        viewModel.isShowingAttendeesView = false
                        viewModel.isShowingPendingView = true
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10)
                                .frame(width: 155, height: 30)
                                .foregroundStyle(viewModel.isShowingPendingView ? .gray.opacity(0.7) : .gray.opacity(0.4))
                            Text("Requests")
                                .foregroundStyle(viewModel.isShowingPendingView ? .black : .gray)
                        }
                    }
                }
                .padding()

                
                if viewModel.isShowingAttendeesView {
                    if viewModel.attendees.count > 0 {
                        List {
                            ForEach(viewModel.attendees) { attendee in
                                AcceptedUserCellView(user: attendee, meetupId: meetup.id)
                            }
                        }
                    } else {
                        Spacer()
                        Text("No one is coming yet, bummer.")
                        Spacer()
                    }
                } else if viewModel.isShowingPendingView {
                    if viewModel.pendingUsers.count > 0 {
                        List {
                            ForEach(viewModel.pendingUsers) { attendee in
                                PendingUserCellView(user: attendee, meetupId: meetup.id)
                            }
                        }
                    } else {
                        Spacer()
                        Text("No pending attendees.")
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(width: 400)
            .background(Color.yellow.edgesIgnoringSafeArea(.all))
            .onAppear {
                Task {
                    try await viewModel.loadAttendees(userIds: meetup.attendees ?? [])
                    try await viewModel.loadPendingUsers(userIds: meetup.pendingUsers ?? [])
                }
            }
        }
    }
}

#Preview {
    MyMeetupView(meetup: Meetup(
        title: "Title",
        description: "description",
        meetTime: Date(),
        city: "Paris",
        country: "France",
        createdDate: Date(),
        organizerId: "organizerId",
        meetSpot: "Spot",
        attendees: [],
        pendingUsers: []
    ))
}
