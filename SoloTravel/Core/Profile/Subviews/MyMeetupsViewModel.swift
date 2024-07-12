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
    
    
    func loadMeetups(userId: String) async throws {
        meetups = try await UserManager.shared.getCreatedUserMeetups(userId: userId)
    }
    
    
    func deleteMeetup(meetupId: String) async throws {
        try await MeetupManager.shared.deleteMeetup(meetupId: meetupId)
    }
}

