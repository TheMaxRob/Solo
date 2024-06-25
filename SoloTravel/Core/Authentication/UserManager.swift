//
//  UserManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage





final class UserManager {
    
    static let shared = UserManager()
    
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    private let storage = Storage.storage()
    
    
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        //        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        //        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    
    func getUser(userId: String) async throws -> DBUser {
        let document = try await userDocument(userId: userId).getDocument()
            
            let user = try document.data(as: DBUser.self, decoder: decoder)
            return user
    }
    
    
    func RSVPMeetup(userId: String, meetup: Meetup) async throws {
        print("RSVPMeetup UserManager called!")
        let docRef = userCollection.document(userId)
        print("docRef")
        let documentSnapshot = try await docRef.getDocument()
            if documentSnapshot.exists {
                print("docSnap exists")
                try await docRef.updateData([
                    "rsvp_meetups": FieldValue.arrayUnion([try encoder.encode(meetup)])
                ])
                print("updateData success")
            } else {
                try await docRef.setData([
                    "rsvp_meetups": [try encoder.encode(meetup)]
                ])
                print("create rsvp_meetups")
            }
    }
    
    
    func createMeetup(userId: String, meetup: Meetup) async throws {
        let docRef = userCollection.document(userId)
                
        let documentSnapshot = try await docRef.getDocument()
        
        if documentSnapshot.exists {
            try await docRef.updateData([
                "created_meetups": FieldValue.arrayUnion([try encoder.encode(meetup)])
            ])
        } else {
            try await docRef.setData([
                "created_meetups": [try encoder.encode(meetup)]
            ])
        }
        
        try await MeetupManager.shared.addMeetup(meetup: meetup)
    }



    // Function to fetch existing meetups array from the user document
    func getCreatedUserMeetups(userId: String) async throws -> [Meetup] {
        print("getCreatedUserMeetups called")
        
        let docRef = userCollection.document(userId)
        
        // Fetch the document
        let document = try await docRef.getDocument()
        print("document fetched")
        
        // Check if the document exists
        if document.exists {
            var existingMeetups = [Meetup]()
            
            if let meetupsData = document.data()?["created_meetups"] as? Data {
                existingMeetups = try decoder.decode([Meetup].self, from: meetupsData)
            } else {
                try await docRef.setData(["created_meetups": []], merge: true)
            }
            
            return existingMeetups
        } else {
            print("User document not found")
            return []
        }
    }
    
    
    func createUserProfile(userId: String,
                           firstName: String,
                           lastName: String,
                           country: String,
                           bio: String,
                           age: String,
                           photoURL: String)
    async throws {
        let snapshot = try await userCollection.document(userId).getDocument()
        if snapshot.exists {
            let userProfile: [String: Any] = [
                "first_name": firstName,
                "last_name": lastName,
                "home_country": country,
                "bio": bio,
                "age": age,
                "photo_url": photoURL
            ]
            try await userCollection.document(userId).updateData(userProfile)
        } else {
            print("No existing user profile found for userId: \(userId). The document must exist to update it.")
            throw NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "User document does not exist."])
        }
    }
    
    
    func uploadImageToFirebase(_ image: UIImage) async throws -> String {
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_pictures/\(fileName).jpg")
        print("storageRef created")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to data."])
        }
        do {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            print("metadata")
            
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            print("putDataAsync")
            let downloadURL = try await storageRef.downloadURL()
            print("downloadURL")
            return downloadURL.absoluteString
        } catch {
            print("Error uploading image: \(error)")
            throw error
        }
    }
    
    
    func loadImage(from url: String) async throws -> UIImage {
        guard let imageURL = URL(string: url) else { return UIImage(systemName: "person.circle.fill")! }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloadedImage = UIImage(data: data) {
                return downloadedImage
            }
        } catch {
            print("Failed to download image: \(error)")
            // Handle error, for example by setting a default image
            return UIImage(systemName: "person.circle.fill")!
        }
        return UIImage(systemName: "person.circle.fill")!
    }

    
    func fetchUserNames(userIds: [String]) async throws -> [String] {
        var usernames: [String] = []
        for userId in userIds {
            let user = try await getUser(userId: userId)
            usernames.append("\(user.firstName ?? "") \(user.lastName ?? "")")
        }
        return usernames
    }
    
    
    enum Error: Swift.Error {
        case tooManyMeetups
    }
}
