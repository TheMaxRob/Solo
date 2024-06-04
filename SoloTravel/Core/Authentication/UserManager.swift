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
      print("createMeetup in UserManager called!")

      // Fetch existing meetups array from the user document (handle empty case)
      var existingMeetups = try await getUserMeetups(userId: userId)
      print("Existing Meetups Fetched")

      // Ensure that the user has not exceeded the maximum number of meetups allowed
      guard existingMeetups.count < 3 else {
        throw Error.tooManyMeetups
      }

      // Append the new meetup to the existing array (optional)
      existingMeetups.append(meetup) // This line can be removed if preferred

      print("Meetup: \(meetup)")
      print("Existing Meetups \(existingMeetups)")

      // Directly update the field in Firestore using arrayUnion
      try await userDocument(userId: userId).updateData([
        DBUser.CodingKeys.createdMeetups.rawValue: FieldValue.arrayUnion([try encoder.encode(meetup)])
      ])
      print("Meetup created successfully!")
    }



    // Function to fetch existing meetups array from the user document
    func getUserMeetups(userId: String) async throws -> [Meetup] {
        let document = try await userDocument(userId: userId).getDocument()
        if let meetupsData = document[DBUser.CodingKeys.createdMeetups.rawValue] as? Data {
            if !meetupsData.isEmpty { // Check if data is not empty
                return try decoder.decode([Meetup].self, from: meetupsData)
            } else {
                return [] // Return empty array if data is empty
            }
        } else {
            // Handle the case where "createdMeetups" is missing entirely
            print("createdMeetups not found in user document")
            return []
        }
    }

    enum Error: Swift.Error {
        case tooManyMeetups
    }

}
