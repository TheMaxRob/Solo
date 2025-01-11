//
//  MeetupDetailsViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/13/24.
//

import SwiftUI

final class MeetupDetailsViewModel: ObservableObject {
    @Published var conversationId: String?
    @Published var host: DBUser? = nil
    @Published var isShowingPersonalMessageView = false
    @Published var image: UIImage? = nil
    @Published var errorMessage: String? = nil
    
    func loadImage(from url: String) async throws {
        image = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func requestRSVP(meetup: Meetup, userId: String) async throws {
        guard !userId.isEmpty else {
            print("userId is empty")
            return
        }
        if (userId == meetup.organizerId) {
            print("Cannot RSVP to your own meetup")
            return
        } else {
            do {
                try await UserManager.shared.requestRSVP(userId: userId, meetupId: meetup.id)
            } catch {
                errorMessage = "Error RSVPing to meetup."
            }
        }
    }
    
    
    func createConversation(with organizerId: String, userId: String) async throws -> String? {
        print("user: \(userId)")
        print("organizer: \(organizerId)")
        guard !userId.isEmpty else { return nil }
        guard !organizerId.isEmpty else { return nil }
        print("createConversation VM, guard passed")
        
        if (userId == organizerId) {
            print("Cannot create chat with yourself.")
            return nil
        } else {
            do {
                print("entered do block")
                let userIds = [userId, organizerId]
                let conversationId = try await MessageManager.shared.createConversation(userIds: userIds)
                isShowingPersonalMessageView = true
                return conversationId
            } catch {
                errorMessage = "Error creating conversation."
                return ""
            }
        }
    }
    
    
    func bookmarkMeetup(userId: String, meetupId: String) async throws {
        try await UserManager.shared.bookmarkMeetup(userId: userId, meetupId: meetupId)
    }
    
    
    func getHost(userId: String) async throws {
        do {
            host = try await UserManager.shared.fetchUser(userId: userId)
        } catch {
            errorMessage = "Error fetching user's profile."
        }
    }
    
    
    func unrequest(meetupId: String, userId: String) async throws {
        do {
            try await MeetupManager.shared.unRequest(meetupId: meetupId, userId: userId)
        } catch {
            errorMessage = "Error removing RSVP request."
        }
        
    }
    
}
