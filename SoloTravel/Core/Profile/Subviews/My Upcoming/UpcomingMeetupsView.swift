//
//  UpcomingMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

@MainActor
final class UpcomingMeetupsViewModel: ObservableObject {
    
    
    @Published var isShowingUpcoming = true
    @Published var isShowingRequested = false
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var host: DBUser = DBUser(userId: "")
    @Published var profileImage: UIImage? = nil
    @Published var acceptedMeetups: [Meetup] = []
    @Published var requestedMeetups: [Meetup] = []
    
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
        if let index = requestedMeetups.firstIndex(where: { $0.id == meetupId }) {
            requestedMeetups.remove(at: index)
        }
    }
    
    
    func unRSVP(meetupId: String, userId: String) async throws {
        print("unRSVP")
        try await MeetupManager.shared.unRSVP(meetupId: meetupId, userId: userId)
        if let index = acceptedMeetups.firstIndex(where: { $0.id == meetupId }) {
            acceptedMeetups.remove(at: index)
        }
    }
    
    
    func getRequestedMeetups(meetupIds: [String]) async throws {
        if meetupIds.isEmpty { return }
        for meetupId in meetupIds {
            try await requestedMeetups.append(MeetupManager.shared.getMeetup(meetupId: meetupId) ?? Meetup(title: "", description: "", meetTime: Date(), city: "", country: "", createdDate: Date(), organizerId: "", meetSpot: "", attendees: [], pendingUsers: []))
        }
    }
    
    
    func getAcceptedMeetups(meetupIds: [String]) async throws {
        if meetupIds.isEmpty { return }
        for meetupId in meetupIds {
            try await acceptedMeetups.append(MeetupManager.shared.getMeetup(meetupId: meetupId) ?? Meetup(title: "", description: "", meetTime: Date(), city: "", country: "", createdDate: Date(), organizerId: "", meetSpot: "", attendees: [], pendingUsers: []))
        }
    }
}


struct UpcomingMeetupsView: View {
    var user: DBUser
    @StateObject var viewModel = UpcomingMeetupsViewModel()
    
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
                .background(.yellow)
                .navigationTitle("Upcoming Meetups")
                .onAppear {
                    Task {
                        try await viewModel.getAcceptedMeetups(meetupIds: user.rsvpMeetups ?? [])
                        try await viewModel.getRequestedMeetups(meetupIds: user.rsvpRequests ?? [])
                    }
                }
                if viewModel.isShowingUpcoming {
                    if viewModel.acceptedMeetups.count > 0 {
                        ForEach(viewModel.acceptedMeetups) { meetup in
                            NavigationLink {
                                OtherAttendeesView(meetup: meetup)
                            } label: {
                                UpcomingMeetupView(viewModel: viewModel, meetup: meetup)
                            }
                        }
                    } else {
                        Spacer()
                        Text("You aren't going to any meetups yet.")
                        Spacer()
                    }
                } else if viewModel.isShowingRequested {
                if viewModel.requestedMeetups.count > 0 {
                    ForEach(viewModel.requestedMeetups) { meetup in
                        RequestedMeetupView(viewModel: viewModel, meetup: meetup)
                    }
                } else {
                        Spacer()
                        Text("No RSVP Requests.")
                        Spacer()
                    }
                }
                Spacer()
            }
            .frame(width: 400)
            .background(.yellow)
        }
    }
}

#Preview {
    UpcomingMeetupsView(user: DBUser(userId: "123", firstName: "Max", lastName: "Roberts"))
}
