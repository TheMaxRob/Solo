//
//  MyMeetupViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/13/24.
//

import SwiftUI

@MainActor
final class MyMeetupViewModel: ObservableObject {
    @Published var isShowingAttendeesView = true
    @Published var isShowingPendingView = false
    @Published var pendingUsers: [DBUser] = []
    @Published var attendees: [DBUser] = []
    @Published var profileImage: UIImage? = nil
    @Published var user: DBUser? = nil
    @Published var errorMessage: String? = nil
    
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loading your profile."
        }
    }

    func loadPendingUsers(userIds: [String]) async throws {
        do {
            if userIds.isEmpty { return }
            for userId in userIds {
                try await pendingUsers.append(UserManager.shared.fetchUser(userId: userId))
            }
        } catch {
            errorMessage = "Error fetching RSVP requests to this meetup."
        }
    }
    
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    
    func loadAttendees(userIds: [String]) async throws {
        do {
            if userIds.isEmpty { return }
            for userId in userIds {
                try await attendees.append(UserManager.shared.fetchUser(userId: userId))
            }
        } catch {
            errorMessage = "Error loading meetup attendees."
        }
    }
    
    
    func acceptRSVP(meetupId: String, userId: String) async throws {
        do {
            if let index = pendingUsers.firstIndex(where: { $0.userId == userId }) {
                   pendingUsers.remove(at: index)
               }
            try await MeetupManager.shared.acceptUserToMeetup(meetupId: meetupId, userId: userId)
            attendees.append(try await UserManager.shared.fetchUser(userId: userId))
        } catch {
            errorMessage = "Error accepting RSVP to meetup."
        }
    }
    
    
    func declineRSVP(meetupId: String, userId: String) async throws {
        do {
            try await MeetupManager.shared.declineUserToMeetup(meetupId: meetupId, userId: userId)
            if let index = pendingUsers.firstIndex(where: { $0.userId == userId }) {
                   pendingUsers.remove(at: index)
               }
        } catch {
            errorMessage = "Error declining RSVP request."
        }
    }
    
    
    func removeUser(meetupId: String, userId: String) async throws {
        do {
            try await MeetupManager.shared.removeUserFromMeetup(meetupId: meetupId, userId: userId)
            if let index = attendees.firstIndex(where: { $0.userId == userId }) {
                   attendees.remove(at: index)
            }
        } catch {
            errorMessage = "Error removing user from meetup."
        }
    }
    
    
    func setNoNewMembers(meetupId: String, userId: String) async throws {
        print("viewModel setNoNewMembers: \(meetupId)")
        try await MeetupManager.shared.setNoNewMembers(meetupId: meetupId, userId: userId)
    }
}
