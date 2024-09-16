//
//  MeetupCreationViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/13/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

final class MeetupCreationViewModel: ObservableObject {
    @Published var alertItem: AlertItem?
    var meetupTitle: String = ""
    var meetupDescription: String = ""
    var meetTime: Date = Date()
    var createdDate: Date = Date()
    var meetSpot: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var imageSelection: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    @Published var errorMessage: String? = nil
    
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loading your account."
        }
    }
    
    
    func loadImage(from item: PhotosPickerItem?) async throws  -> UIImage? {
        guard let item = item else { return nil }
        
        let imageData = try? await item.loadTransferable(type: Data.self)
        if let data = imageData, let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }

    
    
    func createMeetup(userId: String) async throws {
        if let selectedImage {
            do {
                let imageURL = try await UserManager.shared.uploadImageToFirebase(selectedImage)
                let newMeetup = Meetup(title: meetupTitle, description: meetupDescription, meetTime: meetTime, city: city, country: country, createdDate: createdDate, organizerId: user?.userId, meetSpot: meetSpot, attendees: [], pendingUsers: [], imageURL: imageURL)
                try await UserManager.shared.createMeetup(userId: userId, meetup: newMeetup)
            } catch {
                errorMessage = "Error creating meetup."
            }
        }
    }
    
    
    func hasCreatedMeetupWithSameNameAndCity(userId: String, meetupTitle: String, meetupCity: String) async throws -> Bool {
        return try await UserManager.shared.hasCreatedMeetupWithSameNameAndCity(userId: userId, meetupTitle: meetupTitle, meetupCity: meetupCity)
    }
    
    
    func setCity(city: String) {
        let cityCountry = city.split(separator: ", ")
        self.city = String(cityCountry[0])
        self.country = String(cityCountry[1])
    }

}
