//
//  MeetupDetailsViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/13/24.
//

import SwiftUI

final class MeetupDetailsViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var conversationId: String?
    @Published var host: DBUser? = nil
    @Published var isShowingPersonalMessageView = false
    @Published var image: UIImage? = nil
    @Published var errorMessage: String? = nil
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loading your account."
        }
    }
    
    
    func loadImage(from url: String) async throws {
        image = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func requestRSVP(meetup: Meetup) {
        guard let user else {
            print("No user found.")
            return
        }
        
        if (user.userId == meetup.organizerId) {
            print("Cannot RSVP to your own meetup")
            return
        } else {
            Task {
                do {
                    try await UserManager.shared.requestRSVP(userId: user.userId, meetupId: meetup.id)
                } catch {
                    errorMessage = "Error RSVPing to meetup."
                }
            }
        }
    }
    
    
    func createConversation(with organizerId: String) async throws -> String? {
        guard let user else { return nil }
        
        if (user.userId == organizerId) {
            print("Cannot create chat with yourself.")
            return nil
        } else {
            do {
                let userIds = [user.userId, organizerId]
                let conversationId = try await MessageManager.shared.createConversation(userIds: userIds)
                isShowingPersonalMessageView = true
                return conversationId
            } catch {
                errorMessage = "Error creating conversation."
                return ""
            }
        }
    }
    
    
    func getHost(userId: String) async throws {
        do {
            host = try await UserManager.shared.fetchUser(userId: userId)
        } catch {
            errorMessage = "Error fetching user's profile."
        }
    }
    
}
