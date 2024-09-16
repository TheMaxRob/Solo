//
//  UpcomingMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct UpcomingMeetupsView: View {
    var user: DBUser
    @StateObject var viewModel = UpcomingMeetupsViewModel()
    @State private var isErrorAlertPresented = false
    
    var body: some View {
        NavigationStack {
            
            VStack {
                HStack(spacing: 0) {
                    Button(action: {
                        viewModel.isShowingUpcoming = true
                        viewModel.isShowingRequested = false
                    }) {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10)
                                .frame(width: 155, height: 30)
                                .foregroundStyle(viewModel.isShowingUpcoming ? .gray.opacity(0.7) : .gray.opacity(0.4))
                            Text("Upcoming")
                                .foregroundStyle(viewModel.isShowingUpcoming ? .black : .gray)
                        }
                    }
                    Button {
                        viewModel.isShowingUpcoming = false
                        viewModel.isShowingRequested = true
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10)
                                .frame(width: 155, height: 30)
                                .foregroundStyle(viewModel.isShowingRequested ? .gray.opacity(0.7) : .gray.opacity(0.4))
                            Text("Requested")
                                .foregroundStyle(viewModel.isShowingRequested ? .black : .gray)
                        }
                        
                    }
                }
                .padding()
                .navigationTitle("Upcoming Meetups")
                .onAppear {
                    Task {
                        // Reset the meetups to avoid duplication
                        do {
                            viewModel.acceptedMeetups = []
                            viewModel.requestedMeetups = []
                            
                            try await viewModel.loadCurrentUser()
                            try await viewModel.getAcceptedMeetups(meetupIds: user.rsvpMeetups ?? [])
                            try await viewModel.getRequestedMeetups(meetupIds: user.rsvpRequests ?? [])
                            try await viewModel.setHasNewAcceptanceFalse(userId: user.userId)
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }
                }

                if viewModel.isShowingUpcoming {
                        ForEach(viewModel.acceptedMeetups) { meetup in
                            NavigationLink {
                                OtherAttendeesView(meetup: meetup)
                            } label: {
                                UpcomingMeetupView(viewModel: viewModel, meetup: meetup, hostId: meetup.organizerId ?? "")
                            }
                            Spacer()
                        }
                    if (viewModel.acceptedMeetups.count < 1) {
                        Spacer()
                        Text("You aren't going to any meetups yet.")
                        Spacer()
                    }
                } else if viewModel.isShowingRequested {
                if viewModel.requestedMeetups.count > 0 {
                    ForEach(viewModel.requestedMeetups) { meetup in
                        RequestedMeetupView(viewModel: viewModel, meetup: meetup)
                    }
                    Spacer()
                } else {
                        Spacer()
                        Text("No RSVP Requests.")
                        Spacer()
                    }
                }
                Spacer()
            }
            .frame(width: 400)
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            //.background(.yellow)
        }
    }
}

#Preview {
    UpcomingMeetupsView(user: DBUser(userId: "123", firstName: "Max", lastName: "Roberts"))
}
