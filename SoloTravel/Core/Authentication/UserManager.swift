//
//  UserManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



final class UserManager {
    
    static let shared = UserManager()
    
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
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
    
    
    //    func createNewUser(auth: AuthDataResultModel) async throws {
    //
    //        var userData: [String : Any] = [
    //            "user_id" : auth.uid,
    //            "date_created" : Timestamp()
    //        ]
    //
    //        if let email = auth.email {
    //            userData["email"] = email
    //        }
    //        if let url = auth.photoURL {
    //            userData["photo_url"] = url
    //        }
    //
    //        try await userDocument(userId: auth.uid).setData(userData, merge: false)
    //        print("users collection has been added.")
    //
    
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    
    //    func getUser(userId: String) async throws -> DBUser {
    //        let snapshot =  try await userDocument(userId: userId).getDocument()
    //
    //        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
    //            throw URLError(.badServerResponse)
    //        }
    //
    //
    //        let email = data["email"] as? String
    //        let photoURL = data["photo_url"] as? String
    //        let dateCreated = data["date_created"] as? Date
    //
    //        return DBUser(userId: userId, email: email, photoURL: photoURL, dateCreated: dateCreated)
    //    }
    
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


    enum Error: Swift.Error {
        case tooManyMeetups
    }
}
