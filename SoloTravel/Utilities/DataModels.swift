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
    let id: String
    let title: String
    let description: String?
    let meetTime: Date?
    let city: String?
    let country: String?
    let createdDate: Date?
    let organizerId: String?
    let meetSpot: String?
    let attendees: [String]?
    let pendingUsers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case meetTime = "meet_time"
        case city = "city"
        case country = "country"
        case createdDate = "created_date"
        case organizerId = "organizer_id"
        case meetSpot = "meet_spot"
        case attendees = "attendees"
        case pendingUsers = "pending_users"
    }
    
    init(title: String?,
         description: String?,
         meetTime: Date?,
         city: String?,
         country: String?,
         createdDate: Date?,
         organizerId: String?,
         meetSpot: String?,
         attendees: [String]?,
         pendingUsers: [String]?
    )
    
    {
        self.id = UUID().uuidString
        self.title = title ?? ""
        self.description = description ?? ""
        self.meetTime = meetTime ?? Date()
        self.city = city ?? ""
        self.country = country ?? ""
        self.createdDate = createdDate ?? Date()
        self.organizerId = organizerId ?? ""
        self.meetSpot = meetSpot ?? ""
        self.attendees = []
        self.pendingUsers = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.meetTime = try container.decodeIfPresent(Date.self, forKey: .meetTime)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
        self.organizerId = try container.decodeIfPresent(String.self, forKey: .organizerId)
        self.meetSpot = try container.decodeIfPresent(String.self, forKey: .meetSpot)
        self.attendees = try container.decodeIfPresent([String].self, forKey: .attendees)
        self.pendingUsers = try container.decodeIfPresent([String].self, forKey: .pendingUsers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(meetTime, forKey: .meetTime)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(createdDate, forKey: .createdDate)
        try container.encodeIfPresent(organizerId, forKey: .organizerId)
        try container.encodeIfPresent(meetSpot, forKey: .meetSpot)
        try container.encodeIfPresent(attendees, forKey: .attendees)
        try container.encodeIfPresent(pendingUsers, forKey: .pendingUsers)
    }
}




struct Conversation: Codable, Identifiable {
    var id = UUID().uuidString
    let users: [String]
    let lastMessage: String?
    let timestamp: Date?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case users = "users"
        case lastMessage = "last_message"
        case timestamp = "timestamp"
    }
    
    init(
        userIds: [String],
        lastMessage: String,
        createdDate: Date
    ) {
        self.id = UUID().uuidString
        self.users = userIds
        self.lastMessage = lastMessage
        self.timestamp = createdDate
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.users = try container.decode([String].self, forKey: .users)
        self.lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.users, forKey: .users)
        try container.encodeIfPresent(self.lastMessage, forKey: .lastMessage)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
    }
}

struct DBUser: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let photoURL: String?
    let dateCreated: Date?
    let rsvpMeetups: [String]?
    let rsvpRequests: [String]?
    let createdMeetups: [String]?
    let conversations: [String]?
    let homeCountry: String?
    let age: String?
    let bio: String?
    
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.firstName = nil
        self.lastName = nil
        self.rsvpMeetups = []
        self.rsvpRequests = []
        self.createdMeetups = []
        self.conversations = []
        self.homeCountry = ""
        self.age = ""
        self.bio = ""
    }
    
    init(
        userId: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        rsvpMeetups: [String]? = [],
        rsvpRequests: [String]? = [],
        createdMeetups: [String]? = [],
        conversations: [String]? = [],
        homeCountry: String? = nil,
        age: String? = nil,
        bio: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.rsvpMeetups = rsvpMeetups
        self.rsvpRequests = rsvpRequests
        self.createdMeetups = createdMeetups
        self.conversations = conversations
        self.homeCountry = homeCountry
        self.age = age
        self.bio = bio
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
        case rsvpMeetups = "rsvp_meetups"
        case rsvpRequests = "rsvp_requests"
        case createdMeetups = "created_meetups"
        case conversations = "conversations"
        case homeCountry = "home_country"
        case age = "age"
        case bio = "bio"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.rsvpMeetups = try container.decodeIfPresent([String].self, forKey: .rsvpMeetups)
        self.rsvpRequests = try container.decodeIfPresent([String].self, forKey: .rsvpRequests)
        self.createdMeetups = try container.decodeIfPresent([String].self, forKey: .createdMeetups)
        self.conversations = try container.decodeIfPresent([String].self, forKey: .conversations)
        self.homeCountry = try container.decodeIfPresent(String.self, forKey: .homeCountry)
        self.age = try container.decodeIfPresent(String.self, forKey: .age)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
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
        try container.encodeIfPresent(self.rsvpRequests, forKey: .rsvpRequests)
        try container.encodeIfPresent(self.createdMeetups, forKey: .createdMeetups)
        try container.encodeIfPresent(self.conversations, forKey: .conversations)
        try container.encodeIfPresent(self.homeCountry, forKey: .homeCountry)
        try container.encodeIfPresent(self.age, forKey: .age)
        try container.encodeIfPresent(self.bio, forKey: .bio)
    }
    
}
