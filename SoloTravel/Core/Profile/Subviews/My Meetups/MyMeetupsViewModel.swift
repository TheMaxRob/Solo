//
//  MyMeetupsViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import Foundation

@MainActor
final class MyMeetupsViewModel: ObservableObject {
    @Published var meetups: [Meetup] = []
    @Published var errorMessage: String? = nil
    
    func loadMeetups(userId: String) async throws {
        do {
            meetups = try await UserManager.shared.getCreatedUserMeetups(userId: userId)
        } catch {
            errorMessage = "Error loading meetups."
        }
    }
    
    
    func deleteMeetup(meetupId: String, userStateManager: UserStateManager) async throws {
        do {
            try await userStateManager.deleteMeetup(meetupId: meetupId)
            meetups.removeAll(where: { $0.id == meetupId })
        } catch {
            errorMessage = "Error deleting meetup."
        }
    }
}

