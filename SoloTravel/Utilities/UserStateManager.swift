//
//  UserStateManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 9/29/24.
//

import SwiftUI

@MainActor
final class UserStateManager: ObservableObject {
    @Published var currentUser: DBUser?
    @Published var profileImage: UIImage? // Cache for the profile picture
    @Published var meetupCache: [String: Meetup] = [:]
    @Published var intervalMeetupCache: [String: [Meetup]] = [:]
    @Published var imageCache: [String: UIImage] = [:]
    
    func updateUser(_ user: DBUser) {
        self.currentUser = user
    }
    
    
    // Fetch an image with caching
    func fetchImage(from url: String) async throws -> UIImage {
        // Return cached image if available
        if let cachedImage = imageCache[url] {
            print("cached image returned")
            return cachedImage
        }

        // Otherwise, fetch the image
        let image = try await UserManager.shared.loadImage(from: url)
        imageCache[url] = image
        
        return image
    }
    
    
    
    func loadUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.currentUser = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        
        // Load and cache the profile image
        if let _ = currentUser?.photoURL {
            try await loadProfileImage(from: currentUser?.photoURL ?? "")
        }
    }
    
    func refreshUser() async throws {
        guard let userId = currentUser?.userId else { return }
        self.currentUser = try await UserManager.shared.fetchUser(userId: userId)
        
        // Refresh and cache the profile image
        if let _ = currentUser?.photoURL {
            try await loadProfileImage(from: currentUser?.photoURL ?? "")
        }
    }
    
    private func loadProfileImage(from url: String) async throws {
        guard let imageURL = URL(string: url) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloadedImage = UIImage(data: data) {
                self.profileImage = downloadedImage
            }
        } catch {
            print("Failed to load profile image: \(error)")
            self.profileImage = nil // Clear cache on failure
        }
    }
    
    
    func fetchMeetups(start: Date, end: Date) async throws -> [Meetup] {
        // Generate a cache key based on the date range
        let cacheKey = "\(start.timeIntervalSince1970)_\(end.timeIntervalSince1970)"
        
        // Check if the meetups for the date range are already cached
        if let cachedMeetups = intervalMeetupCache[cacheKey] {
            print("cached meetups returned")
            return cachedMeetups
        }
        
        // Fetch meetups from the database
        let meetups = try await MeetupManager.shared.fetchMeetups(start: start, end: end)
        
        // Cache the result
        intervalMeetupCache[cacheKey] = meetups
        
        return meetups
    }

    
    
    func fetchMeetup(meetupId: String) async throws -> Meetup {
        if let cachedMeetup = meetupCache[meetupId] {
            print("cached meetup returned")
            return cachedMeetup
        }
        
        let meetup = try await MeetupManager.shared.fetchMeetup(meetupId: meetupId)
        meetupCache[meetupId] = meetup
        return meetup ?? Meetup()
    }
    
    
    func cacheMeetups(_ meetups: [Meetup]) {
        for meetup in meetups {
            meetupCache[meetup.id] = meetup
        }
    }
    
    
    func clearMeetupCache() {
        meetupCache.removeAll()
    }
}

