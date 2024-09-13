//
//  UpcomingMeetupsViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 8/4/24.
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
    
    
    func setHasNewAcceptanceFalse(userId: String) async throws {
        try await UserManager.shared.setHasNewAcceptanceFalse(userId: userId)
    }
    
    
    func getHost(userId: String) async throws {
        print("getHost called with \(userId)")
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
            try await requestedMeetups.append(MeetupManager.shared.getMeetup(meetupId: meetupId) ?? Meetup(title: "", description: "", meetTime: Date(), city: "", country: "", createdDate: Date(), organizerId: "", meetSpot: "", attendees: [], pendingUsers: [], imageURL: ""))
        }
        
        print("requestedMeetups: \(requestedMeetups)")
    }
    
    
    func getAcceptedMeetups(meetupIds: [String]) async throws {
        if meetupIds.isEmpty { return }
        for meetupId in meetupIds {
            try await acceptedMeetups.append(MeetupManager.shared.getMeetup(meetupId: meetupId) ?? Meetup(title: "", description: "", meetTime: Date(), city: "", country: "", createdDate: Date(), organizerId: "", meetSpot: "", attendees: [], pendingUsers: [], imageURL: ""))
        }
    }
}

