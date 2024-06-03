//
//  DataModels.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/3/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    let senderId: String
    let recipientId: String
    let content: String
    let timestamp: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case content
        case timestamp
    }
}

struct Conversation: Codable, Identifiable {
    @DocumentID var id: String?
    let users: [String]
    let lastMessage: String?
    let timestamp: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id
        case users
        case lastMessage = "last_message"
        case timestamp
    }
}

struct DBUser: Codable {
    let userId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let photoURL: String?
    let dateCreated: Date?
    let meetups: [Meetup]?
    let preferences: [String]?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.firstName = nil
        self.lastName = nil
        self.meetups = nil
        self.preferences = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        meetups: [Meetup]? = nil,
        preferences: [String]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.meetups = meetups
        self.preferences = preferences
    }
    
    
//    mutating func togglePremiumStatus() {
//        let currentValue = isPremium ?? false
//        isPremium = !currentValue
//    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
        case preferences = "preferences"
        case meetups = "meetups"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.meetups = try container.decodeIfPresent([Meetup].self, forKey: .meetups)

    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.meetups, forKey: .meetups)
    }
    
}

