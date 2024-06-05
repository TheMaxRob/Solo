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
        guard let data = try? encoder.encode(meetup) else {
            throw URLError(.badURL)
        }
        let dict: [String:Any] = [
            DBUser.CodingKeys.rsvpMeetups.rawValue : data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    
    func createMeetup(userId: String, meetup: Meetup) async throws {
//      // Fetch existing meetups array from the user document (handle empty case)
//      var existingMeetups = try await getCreatedUserMeetups(userId: userId)
//      // Ensure that the user has not exceeded the maximum number of meetups allowed
//      guard existingMeetups.count < 3 else {
//        throw Error.tooManyMeetups
//      }
//
//      existingMeetups.append(meetup)
//        print("Existing Meetups: \(existingMeetups)")
//      do {
//         let data = try? encoder.encode(existingMeetups)
//          print("Existing Meetups as Data: ", data)
//         let dict: [String:Any] = [
//            DBUser.CodingKeys.createdMeetups.rawValue : FieldValue.arrayUnion([data])
//         ]
//          
//          try await userDocument(userId: userId).updateData(dict)
//         
//      } catch {
//          print("Error: \(error)")
//      }
//         
//        
//
//        print("arrayUnion successful")
//        try await MeetupManager.shared.addMeetup(meetup: meetup)
//    
//    
//      print("Meetup created successfully!")
        
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
            
            // Check if the created_meetups field exists
            if let meetupsData = document.data()?["created_meetups"] as? Data {
                // Decode the existing meetups from the data
                existingMeetups = try decoder.decode([Meetup].self, from: meetupsData)
            } else {
                // If the created_meetups field doesn't exist, create an empty array
                try await docRef.setData(["created_meetups": []], merge: true)
            }
            
            return existingMeetups
        } else {
            // Handle the case where the document doesn't exist
            print("User document not found")
            return []
        }
    }


    enum Error: Swift.Error {
        case tooManyMeetups
    }
}
