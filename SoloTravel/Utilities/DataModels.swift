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
        case id = "id"
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case content = "content"
        case timestamp = "timestamp"
    }
}


struct Meetup: Identifiable, Codable {
    @DocumentID var id = UUID().uuidString
    let title: String
    let description: String?
    let meetTime: Date
    let city: String
    let createdDate: Date
    let organizerId: String
    let meetSpot: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case meetTime
        case city
        case createdDate
        case organizerId
        case meetSpot
    }
    
    init(id: String, 
         title: String,
         description: String?,
         meetTime: Date, 
         city: String,
         createdDate: Date, 
         organizerId: String,
         meetSpot: String)
    
    {
        self.id = id
        self.title = title
        self.description = description
        self.meetTime = meetTime
        self.city = city
        self.createdDate = createdDate
        self.organizerId = organizerId
        self.meetSpot = meetSpot
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.meetTime = try container.decode(Date.self, forKey: .meetTime)
        self.city = try container.decode(String.self, forKey: .city)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.organizerId = try container.decode(String.self, forKey: .organizerId)
        self.meetSpot = try container.decode(String.self, forKey: .meetSpot)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(meetTime, forKey: .meetTime)
        try container.encode(city, forKey: .city)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(organizerId, forKey: .organizerId)
        try container.encode(meetSpot, forKey: .meetSpot)
    }
}




struct Conversation: Codable, Identifiable {
    var id = UUID().uuidString
    let users: [String]
    let lastMessage: String?
    let timestamp: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case users
        case lastMessage = "last_message"
        case timestamp
    }
    
    init(
        id: String,
        userIds: [String],
        lastMessage: String,
        createdDate: Date
    ) {
        self.id = id
        self.users = userIds
        self.lastMessage = lastMessage
        self.timestamp = createdDate
    }
}

struct DBUser: Codable {
    let userId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let photoURL: String?
    let dateCreated: Date?
    let rsvpMeetups: [Meetup]?
    let createdMeetups: [Meetup]?
    let conversations: [Conversation]?
    let homeCountry: String?
    let birthDate: Date?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.firstName = nil
        self.lastName = nil
        self.rsvpMeetups = []
        self.createdMeetups = []
        self.conversations = []
        self.homeCountry = ""
        self.birthDate = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        rsvpMeetups: [Meetup]? = [],
        createdMeetups: [Meetup]? = [],
        conversations: [Conversation]? = [],
        homeCountry: String? = nil,
        birthDate: Date? = nil
    ) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.rsvpMeetups = rsvpMeetups
        self.createdMeetups = createdMeetups
        self.conversations = conversations
        self.homeCountry = homeCountry
        self.birthDate = birthDate
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
        case rsvpMeetups = "rsvp_meetups"
        case createdMeetups = "created_meetups"
        case conversations = "conversations"
        case homeCountry = "home_country"
        case birthDate = "birth_date"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.rsvpMeetups = try container.decodeIfPresent([Meetup].self, forKey: .rsvpMeetups)
        self.createdMeetups = try container.decodeIfPresent([Meetup].self, forKey: .createdMeetups)
        self.conversations = try container.decodeIfPresent([Conversation].self, forKey: .conversations)
        self.homeCountry = try container.decodeIfPresent(String.self, forKey: .homeCountry)
        self.birthDate = try container.decodeIfPresent(Date.self, forKey: .birthDate)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.rsvpMeetups, forKey: .rsvpMeetups)
        try container.encodeIfPresent(self.createdMeetups, forKey: .createdMeetups)
        try container.encodeIfPresent(self.conversations, forKey: .conversations)
        try container.encodeIfPresent(self.homeCountry, forKey: .homeCountry)
        try container.encodeIfPresent(self.birthDate, forKey: .birthDate)
    }
    
}
