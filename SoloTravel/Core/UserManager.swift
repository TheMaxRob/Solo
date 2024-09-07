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
    private let meetupsCollection = Firestore.firestore().collection("meetups")
    private let meetupsIndexCollection = Firestore.firestore().collection("meetup_index")
    private let storage = Storage.storage()
    
    
    func userDocument(userId: String) -> DocumentReference {
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
    
    
    func sendResetPasswordEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                print("Error sending reset email: \(error)")
            } else {
                print("Reset email sent!")
            }
        }
    }
    
    
    func getUser(userId: String) async throws -> DBUser {
        let document = try await userDocument(userId: userId).getDocument()
        let data = document.data()
        let user = try decoder.decode(DBUser.self, from: data ?? DBUser(userId: ""))
        return user
    }
    
    
    func requestRSVP(userId: String, meetupId: String) async throws {
        let userRef = userCollection.document(userId)
        let documentSnapshot = try await userRef.getDocument()
        
        if documentSnapshot.exists {
            var rsvpRequests = documentSnapshot.data()?["rsvp_requests"] as? [String] ?? []
            let rsvpMeetups = documentSnapshot.data()?["rsvp_meetups"] as? [String] ?? []
            if !rsvpRequests.contains(meetupId) && !rsvpMeetups.contains(meetupId) {
                rsvpRequests.append(meetupId)
                try await userRef.updateData([
                    "rsvp_requests" : rsvpRequests
                ])
                try await MeetupManager.shared.addPendingUser(meetupId: meetupId, userId: userId)
            } else {
                print("User already requested RSVP for meetup \(meetupId)")
            }
        } else {
            try await userRef.setData([
                "rsvp_requests": [meetupId]
            ])
        }
    }
    
    
//    func requestRSVP(userId: String, meetup: Meetup) async throws {
//        let docRef = userCollection.document(userId)
//        let snapshot = try await docRef.getDocument()
//        if snapshot.exists {
//            try await docRef.updateData([
//            
//            ])
//        }
//    }
    
    
    func createMeetup(userId: String, meetup: Meetup) async throws {
        let docRef = userCollection.document(userId)
        
        let documentSnapshot = try await docRef.getDocument()
        
        if documentSnapshot.exists {
            try await docRef.updateData([
                "created_meetups" : FieldValue.arrayUnion([meetup.id])
            ])
        } else {
            try await docRef.setData([
                "created_meetups" : [meetup.id]
            ])
        }
        
        print("meetup sent to MeetupManager addMeetup: \(meetup)")
        try await MeetupManager.shared.addMeetup(meetup: meetup)
    }



    // Function to fetch existing meetups array from the user document
    func getCreatedUserMeetups(userId: String) async throws -> [Meetup] {
        let userRef = userCollection.document(userId)
        
        let userDocument = try await userRef.getDocument()
        var meetups: [Meetup] = []
        if userDocument.exists {
            if let data = userDocument.data() {
                if let meetupIds = data["created_meetups"] as? [String] {
                    for meetupId in meetupIds {
                        let indexRef = meetupsIndexCollection.document(meetupId)
                        let indexSnapshot = try await indexRef.getDocument()
                        if let indexData = indexSnapshot.data() {
                            if
                                let city = indexData["city"] as? String,
                                let country = indexData["country"] as? String {
                                let snapshot = try await meetupsCollection.document(country).collection(city).document(meetupId).getDocument()
                                if let dict = snapshot.data() {
                                    if let meetup = try? decoder.decode(Meetup.self, from: dict) {
                                        meetups.append(meetup)
                                    }
//                                    guard
//                                        let id = dict["id"] as? String,
//                                        let title = dict["title"] as? String?,
//                                        let description = dict["description"] as? String?,
//                                        let city = dict["city"] as? String?,
//                                        let country = dict["country"] as? String?,
//                                        let organizerId = dict["organizer_id"] as? String?,
//                                        let meetSpot = dict["meet_spot"] as? String?,
//                                        let createdDateTimestamp = dict["created_date"] as? Timestamp?,
//                                        let meetTimeTimestamp = dict["meet_time"] as? Timestamp?,
//                                        let attendees = dict["attendees"] as? [String]?,
//                                        let pendingAttendees = dict["pending_attendees"] as? [String]? else {
//                                        print("Can't decode meetup.")
//                                        continue
//                                    }
//                                    let createdDate = createdDateTimestamp?.dateValue()
//                                    let meetTime = meetTimeTimestamp?.dateValue()
//                                    
//                                    let meetup = Meetup(
//                                        title: title,
//                                        description: description,
//                                        meetTime: meetTime,
//                                        city: city,
//                                        country: country,
//                                        createdDate: createdDate,
//                                        organizerId: organizerId,
//                                        meetSpot: meetSpot,
//                                        attendees: attendees,
//                                        pendingAttendees: pendingAttendees
//                                    )
//                                    meetups.append(meetup)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        return meetups
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
        print("imageURL: \(url)")
        guard let imageURL = URL(string: url) else {
            return UIImage(systemName: "person.circle.fill")!
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloadedImage = UIImage(data: data) {
                return downloadedImage
            }
        } catch {
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
    
    
    func updateUserInformation(userId: String, fields: [String : Any]) async throws {
        let userRef = userCollection.document(userId)
        try await userRef.updateData(fields)
        
    }
    
//    private func deleteStorageImage(url: String) async throws {
//        let storageRef = storage.reference(forURL: url)
//        try await storageRef.delete()
//    }
    
    
    func hasCreatedMeetupWithSameNameAndCity(userId: String, meetupTitle: String, meetupCity: String) async throws -> Bool {
        let userMeetups = try await getCreatedUserMeetups(userId: userId)
            for userMeetup in userMeetups {
                if userMeetup.title == meetupTitle && userMeetup.city == meetupCity {
                    return true
                }
            }
            return false
    }
    private func fetchUserMeetupNames(userId: String) async throws -> [String] {
        let userRef = userCollection.document(userId)
        let snapshot = try await userRef.getDocument()
        if snapshot.exists {
            var meetupNames: [String] = []
            meetupNames = snapshot.data()?[DBUser.CodingKeys.createdMeetups.rawValue] as? [String] ?? []
            return meetupNames
        } else { return [] }
    }
    
    
    func setUserMessagesRead(userId: String) async throws {
        let userRef = userCollection.document(userId)
        let snapshot = try await userRef.getDocument()
        if snapshot.exists {
            try await userRef.updateData([
                DBUser.CodingKeys.hasUnreadMessages.rawValue : false
            ])
        }
    }
    
    
    enum Error: Swift.Error {
        case tooManyMeetups
    }
}
