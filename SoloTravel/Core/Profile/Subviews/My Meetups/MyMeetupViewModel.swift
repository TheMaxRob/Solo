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
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        print("authDataResult created")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }

    func loadPendingUsers(userIds: [String]) async throws {
        if userIds.isEmpty { return }
        for userId in userIds {
            try await pendingUsers.append(UserManager.shared.getUser(userId: userId))
        }
    }
    
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    
    func loadAttendees(userIds: [String]) async throws {
        if userIds.isEmpty { return }
        for userId in userIds {
            try await attendees.append(UserManager.shared.getUser(userId: userId))
        }
    }
    
    
    func acceptRSVP(meetupId: String, userId: String) async throws {
        print("acceptRSVP")
        if let index = pendingUsers.firstIndex(where: { $0.userId == userId }) {
               pendingUsers.remove(at: index)
           }
        try await MeetupManager.shared.acceptUserToMeetup(meetupId: meetupId, userId: userId)
        attendees.append(try await UserManager.shared.getUser(userId: userId))
    }
    
    
    func declineRSVP(meetupId: String, userId: String) async throws {
        print("declineRSVP")
        
        try await MeetupManager.shared.declineUserToMeetup(meetupId: meetupId, userId: userId)
        if let index = pendingUsers.firstIndex(where: { $0.userId == userId }) {
               pendingUsers.remove(at: index)
           }
    }
    
    
    func removeUser(meetupId: String, userId: String) async throws {
        try await MeetupManager.shared.removeUserFromMeetup(meetupId: meetupId, userId: userId)
        if let index = attendees.firstIndex(where: { $0.userId == userId }) {
               attendees.remove(at: index)
           }
    }
    
    
    func setNoNewMembers(meetupId: String, userId: String) async throws {
        print("viewModel setNoNewMembers: \(meetupId)")
        try await MeetupManager.shared.setNoNewMembers(meetupId: meetupId, userId: userId)
    }
}
