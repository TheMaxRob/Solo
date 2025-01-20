//
//  MeetupCreationViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/13/24.
//

import SwiftUI
import _PhotosUI_SwiftUI
import MapboxMaps

@MainActor
final class MeetupCreationViewModel: ObservableObject {
    @Published var alertItem: AlertItem?
    var meetupTitle: String = ""
    var meetupDescription: String = ""
    var meetTime: Date = Date()
    var createdDate: Date = Date()
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    @Published var errorMessage: String? = nil
    
    
    @Published private(set) var user: DBUser? = nil    
    
    func loadImage(from item: PhotosPickerItem?) async throws  -> UIImage? {
        guard let item = item else { return nil }
        
        let imageData = try? await item.loadTransferable(type: Data.self)
        if let data = imageData, let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
    
    
    func hasCreatedMeetupNearLocation(userId: String, meetupTitle: String, location: CLLocationCoordinate2D) async throws -> Bool {
            // Implement logic to check for nearby meetups
            // You might want to check within a certain radius (e.g., 100 meters)
            // Return true if a meetup exists nearby
            return false // Placeholder
    }
    
    
    func createMeetup(userId: String, location: CLLocationCoordinate2D) async throws {
        print("creating Meetup with userId \(userId)")
        if let selectedImage {
            do {
                let imageURL = try await UserManager.shared.uploadImageToFirebase(selectedImage, userId: userId)
                let newMeetup = Meetup(title: meetupTitle, description: meetupDescription, meetTime: meetTime, city: city, createdDate: createdDate, organizerId: userId, location: location, attendees: [], pendingUsers: [], imageURL: imageURL)
                try await UserManager.shared.createMeetup(userId: userId, meetup: newMeetup)
            } catch {
                errorMessage = "Error creating meetup."
            }
        }
    }
    
    
//    func hasCreatedMeetupWithSameNameAndCity(userId: String, meetupTitle: String, meetupCity: String) async throws -> Bool {
//        return try await UserManager.shared.hasCreatedMeetupWithSameNameAndCity(userId: userId, meetupTitle: meetupTitle, meetupCity: meetupCity)
//    }
    
    
    func setCity(city: String) {
        let cityCountry = city.split(separator: ", ")
        self.city = String(cityCountry[0])
        self.country = String(cityCountry[1])
    }

}
