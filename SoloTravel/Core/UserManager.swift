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
    private let reportsCollection = Firestore.firestore().collection("reports")
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
        guard !user.userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }
        do {
            try userDocument(userId: user.userId).setData(from: user, merge: false)
        } catch {
            print("Error creating new user: \(error)")
        }
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
    
    
    func fetchUser(userId: String) async throws -> DBUser {
        
        guard !userId.isEmpty else {
            print("userId not found – fetchUser")
            throw UserManagerError.invalidUserId
        }
        
        do {
            let document = try await userCollection.document(userId).getDocument()
            if document.exists, let data = document.data() {
                let user = try decoder.decode(DBUser.self, from: data)
                return user
            } else {
                print("document not found – fetchUser")
                throw UserManagerError.userNotFound
            }
        } catch {
            print("Error fetching user: \(error)")
            throw error
        }
    }
    
    
    func requestRSVP(userId: String, meetupId: String) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        let userRef = userCollection.document(userId)
        
        do {
            let documentSnapshot = try await userRef.getDocument()
            
            if documentSnapshot.exists {
                var rsvpRequests = documentSnapshot.data()?[DBUser.CodingKeys.rsvpRequests.rawValue] as? [String] ?? []
                let rsvpMeetups = documentSnapshot.data()?[DBUser.CodingKeys.rsvpMeetups.rawValue] as? [String] ?? []
                if !rsvpRequests.contains(meetupId) && !rsvpMeetups.contains(meetupId) {
                    rsvpRequests.append(meetupId)
                    try await userRef.updateData([
                        DBUser.CodingKeys.rsvpRequests.rawValue : rsvpRequests
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
        } catch {
            print("Error requesting RSVP: \(error)")
            throw error
        }
    }
    
    func createMeetup(userId: String, meetup: Meetup) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        let docRef = userCollection.document(userId)
        
        do {
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
        } catch {
            print("Error creating meetup: \(error)")
            throw error
        }
    }



    // Function to fetch existing meetups array from the user document
    func getCreatedUserMeetups(userId: String) async throws -> [Meetup] {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        let userRef = userCollection.document(userId)
        var meetups: [Meetup] = []
        
        do {
            let userDocument = try await userRef.getDocument()
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
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return meetups
        } catch {
            print("Error fetching created meetups: \(error)")
            throw error
        }
        
    }


    
    
    func createUserProfile(userId: String,
                           firstName: String,
                           lastName: String,
                           country: String,
                           bio: String,
                           age: String,
                           photoURL: String) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        do {
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
        } catch {
            print("Error creating user profile: \(error)")
            throw error
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
        do {
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
        } catch {
            print("Error loading image: \(error)")
            throw error
        }
    }

    
    func fetchUserNames(userIds: [String]) async throws -> [String] {
        do {
            var usernames: [String] = []
            
            try await withThrowingTaskGroup(of: String?.self) { group in
                for userId in userIds {
                    guard !userId.isEmpty else {
                        throw UserManagerError.invalidUserId
                    }

                    group.addTask {
                        let userRef = self.userCollection.document(userId)
                        let document = try? await userRef.getDocument()
                        
                        if let data = document?.data(),
                           let firstName = data[DBUser.CodingKeys.firstName.rawValue] as? String,
                           let lastName = data[DBUser.CodingKeys.lastName.rawValue] as? String {
                            return "\(firstName) \(lastName)"
                        } else {
                            return nil
                        }
                    }
                }
                
                for try await username in group {
                    if let username = username {
                        usernames.append(username)
                    }
                }
            }
            
            return usernames
        } catch {
            print("Error fetching user names: \(error)")
            throw error
        }
    }
    
    
    func updateUserInformation(userId: String, fields: [String : Any]) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        let userRef = userCollection.document(userId)
        do {
            try await userRef.updateData(fields)
        } catch {
            print("Error updating user \(userId)'s fields \(fields): \(error)")
            throw error
        }
    }
    
//    private func deleteStorageImage(url: String) async throws {
//        let storageRef = storage.reference(forURL: url)
//        try await storageRef.delete()
//    }
    
    
    func hasCreatedMeetupWithSameNameAndCity(userId: String, meetupTitle: String, meetupCity: String) async throws -> Bool {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        do {
            let userMeetups = try await getCreatedUserMeetups(userId: userId)
                for userMeetup in userMeetups {
                    if userMeetup.title == meetupTitle && userMeetup.city == meetupCity {
                        return true
                    }
                }
                return false
        } catch {
            print("Error determining if user has created a meetup with the same name in that city: \(error)")
            throw error
        }
    }
    
    private func fetchUserMeetupNames(userId: String) async throws -> [String] {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        let userRef = userCollection.document(userId)
        
        do {
            let snapshot = try await userRef.getDocument()
            if snapshot.exists {
                var meetupNames: [String] = []
                meetupNames = snapshot.data()?[DBUser.CodingKeys.createdMeetups.rawValue] as? [String] ?? []
                return meetupNames
            } else { return [] }
        } catch {
            print("Error fetching user meetup names: \(error)")
            throw error
        }
    }
    
    
    func setUserMessagesRead(userId: String) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }
        let userRef = userCollection.document(userId)
        
        do {
            let snapshot = try await userRef.getDocument()
            if snapshot.exists {
                try await userRef.updateData([
                    DBUser.CodingKeys.hasUnreadMessages.rawValue : false
                ])
            }
        } catch {
            print("Error setting user messages to read: \(error)")
            throw error
        }
    }
    
    
    func blockUser(userId: String, blockedUser: String) async throws {
        
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        guard !blockedUser.isEmpty else {
            throw UserManagerError.invalidUserId
        }
        
        let userRef = userCollection.document(userId)
        let blockedUserRef = userCollection.document(blockedUser)

        do {
            let snapshot = try await userRef.getDocument()
            if snapshot.exists {
                do {
                    try await userRef.updateData([
                        DBUser.CodingKeys.blockedUsers.rawValue : FieldValue.arrayUnion([blockedUser])
                    ])
                } catch {
                    print("Error blocking user: \(error)")
                }
            }
            
            let blockedUserSnapshot = try await blockedUserRef.getDocument()
            if blockedUserSnapshot.exists {
                do {
                    try await blockedUserRef.updateData([
                        DBUser.CodingKeys.blockedBy.rawValue : FieldValue.arrayUnion([userId])
                    ])
                } catch {
                    print("Error blocking user: \(error)")
                    throw error
                }
            }
        } catch {
            print("Error blocking user: \(error)")
            throw error
        }
    }
    
    
    func unblockUser(userId: String, blockedUser: String) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        guard !blockedUser.isEmpty else {
            throw UserManagerError.invalidUserId
        }

        
        let userRef = userCollection.document(userId)
        let blockedUserRef = userCollection.document(blockedUser)
        
        do {
            let snapshot = try await userRef.getDocument()
            if snapshot.exists {
                do {
                    print("removing \(blockedUser) from \(userId)'s blockedUsers list")
                    try await userRef.updateData([
                        DBUser.CodingKeys.blockedUsers.rawValue : FieldValue.arrayRemove([blockedUser])
                    ])
                } catch {
                    print("Error blocking user: \(error)")
                    throw error
                }
            }
            
            
            let blockedUserSnapshot = try await blockedUserRef.getDocument()
            if blockedUserSnapshot.exists {
                do {
                    print("removing \(userId) from \(blockedUser)'s blockedBy list")
                    try await blockedUserRef.updateData([
                        DBUser.CodingKeys.blockedBy.rawValue : FieldValue.arrayRemove([userId])
                    ])
                } catch {
                    print("Error blocking user: \(error)")
                }
            }
        } catch {
            print("Error unblocking user: \(error)")
            throw error
        }
    }
    
    
    func setHasNewAcceptanceFalse(userId: String) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }
        let userRef = userCollection.document(userId)
        
        do {
            let snapshot = try await userRef.getDocument()
            if snapshot.exists {
                try await userRef.updateData([
                    "has_new_acceptance" : false
                ])
            }
        } catch {
            print("Error setting hasNewAcceptance to false: \(error)")
            throw error
        }
    }
    
    
    func reportUser(userId: String, reportedUserId: String, content: String) async throws {
        guard !userId.isEmpty else {
            throw UserManagerError.invalidUserId
        }
        
        let userRef = userCollection.document(userId)
        
        do {
            let snapshot = try await userRef.getDocument()
            
            if snapshot.exists {
                // Add reported user to the user's reported list
                try await userRef.updateData([
                    DBUser.CodingKeys.reportedUsers.rawValue : FieldValue.arrayUnion([reportedUserId])
                ])
                
                // Add a document to the "reports" collection with the reportedUserId as the document ID
                let reportData: [String: Any] = [
                    "reported_by": userId,
                    "timestamp": Timestamp(),
                    "reason": content
                ]
                
                try await reportsCollection.document(reportedUserId).setData(reportData)
                
            } else {
                throw UserManagerError.userNotFound
            }
        } catch {
            print("Error reporting user: \(error)")
            throw error
        }
    }

}


enum UserManagerError: Error {
    case userNotFound
    case firestoreError(Error)
    case invalidUserId
}
