//
//  UserManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable, Hashable {
    let userId: String
    let email: String?
    let photoURL: String?
    let dateCreated: Date?
    let RSVPMeetups: [Meetup]?
    // let preferences: [String]?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.RSVPMeetups = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        RSVPMeetups: [Meetup]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.RSVPMeetups = RSVPMeetups
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
        case RSVPMeetups = "rsvp_meetups"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.RSVPMeetups = try container.decodeIfPresent([Meetup].self, forKey: .RSVPMeetups)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.RSVPMeetups, forKey: .RSVPMeetups)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    
    func RSVPMeetup(userId: String) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.RSVPMeetups.rawValue : FieldValue.arrayUnion([RSVPMeetups])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
}

