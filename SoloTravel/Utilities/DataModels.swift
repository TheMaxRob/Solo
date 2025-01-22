//
//  DataModels.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/3/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import MapboxMaps
import CoreLocation


enum Tag: String, Codable, CaseIterable, Equatable {
    case hiking = "Hiking"
    case cooking = "Cooking"
    case reading = "Reading"
    case sightseeing = "Sightseeing"
    case nightlife = "Nightlife"
    case photography = "Photography"
    case sports = "Sports"
    case gaming = "Gaming"
    case food = "Food"
    case party = "Party"
    case workshop = "Workshop"
    case museum = "Museum"
    case beach = "Beach"
    case coffee = "Coffee"
    case concert = "Concert"
}


struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    let senderId: String
    let recipientId: String
    let content: String
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case content = "content"
        case timestamp = "timestamp"
    }
    
    init(
        senderId: String,
        recipientId: String,
        content: String,
        timestamp: Date
    ) {
        self.senderId = senderId
        self.recipientId = recipientId
        self.content = content
        self.timestamp = timestamp
    }
}



struct Meetup: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let description: String?
    let meetTime: Date?
    let city: String?
    let createdDate: Date?
    let organizerId: String?
    let location: CLLocationCoordinate2D
    let attendees: [String]?
    let pendingUsers: [String]?
    let imageURL: String?
    let hasNewMember: Bool?
    let tags: [Tag]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case meetTime = "meet_time"
        case city = "city"
        case createdDate = "created_date"
        case organizerId = "organizer_id"
        case location = "location"
        case attendees = "attendees"
        case pendingUsers = "pending_users"
        case imageURL = "image_url"
        case hasNewMember = "has_new_member"
        case tags = "tags"
    }
    
    init () {
        self.id = UUID().uuidString
        self.title = ""
        self.description = ""
        self.meetTime = Date()
        self.city = ""
        self.createdDate = Date()
        self.organizerId = ""
        self.location = CLLocationCoordinate2D()
        self.attendees = []
        self.pendingUsers = []
        self.imageURL = ""
        self.hasNewMember = false
        self.tags = []
    }
    
    init(title: String?,
         description: String?,
         meetTime: Date?,
         city: String?,
         createdDate: Date?,
         organizerId: String?,
         location: CLLocationCoordinate2D,
         attendees: [String]?,
         pendingUsers: [String]?,
         imageURL: String?,
         tags: [Tag]?
    )
    
    {
        self.id = UUID().uuidString
        self.title = title ?? ""
        self.description = description ?? ""
        self.meetTime = meetTime ?? Date()
        self.city = city ?? ""
        self.createdDate = createdDate ?? Date()
        self.organizerId = organizerId ?? ""
        self.location = location
        self.attendees = []
        self.pendingUsers = []
        self.imageURL = imageURL ?? ""
        self.hasNewMember = false
        self.tags = tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.meetTime = try container.decodeIfPresent(Date.self, forKey: .meetTime)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
        self.organizerId = try container.decodeIfPresent(String.self, forKey: .organizerId)
        self.attendees = try container.decodeIfPresent([String].self, forKey: .attendees)
        self.pendingUsers = try container.decodeIfPresent([String].self, forKey: .pendingUsers)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.hasNewMember = try container.decodeIfPresent(Bool.self, forKey: .hasNewMember)
        self.tags = try container.decodeIfPresent([Tag].self, forKey: .tags)
        if let geoPoint = try container.decodeIfPresent(GeoPoint.self, forKey: .location) {
            self.location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .location, in: container, debugDescription: "Location is missing or invalid")
        }
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
        try container.encodeIfPresent(attendees, forKey: .attendees)
        try container.encodeIfPresent(pendingUsers, forKey: .pendingUsers)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(hasNewMember, forKey: .hasNewMember)
        try container.encodeIfPresent(tags, forKey: .tags)
        
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        try container.encode(geoPoint, forKey: .location)

    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(meetTime)
        hasher.combine(city)
        hasher.combine(createdDate)
        hasher.combine(organizerId)
        hasher.combine(location.latitude)
        hasher.combine(location.longitude)
        hasher.combine(attendees)
        hasher.combine(pendingUsers)
        hasher.combine(imageURL)
        hasher.combine(hasNewMember)
        hasher.combine(tags)
    }
}




struct Conversation: Codable, Identifiable {
    var id: String
    let users: [String]
    var lastMessage: String?
    let timestamp: Date?
    var messages: [Message]?
    var hasUnreadMessages: Bool
    var mostRecentSenderId: String
    

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case users = "users"
        case lastMessage = "last_message"
        case timestamp = "timestamp"
        case messages = "messages"
        case hasUnreadMessages = "has_unread_messages"
        case mostRecentSenderId = "most_recent_sender_id"
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
        self.messages = []
        self.hasUnreadMessages = false
        self.mostRecentSenderId = ""
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.users = try container.decode([String].self, forKey: .users)
        self.lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.messages = try container.decodeIfPresent([Message].self, forKey: .messages)
        self.hasUnreadMessages = try container.decode(Bool.self, forKey: .hasUnreadMessages)
        self.mostRecentSenderId = try container.decode(String.self, forKey: .mostRecentSenderId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.users, forKey: .users)
        try container.encodeIfPresent(self.lastMessage, forKey: .lastMessage)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.messages, forKey: .messages)
        try container.encode(self.hasUnreadMessages, forKey: .hasUnreadMessages)
        try container.encode(self.mostRecentSenderId, forKey: .mostRecentSenderId)
    }
}

struct DBUser: Codable, Identifiable, Equatable {
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
    var hasUnreadMessages: Bool?
    var blockedUsers: [String]?
    var blockedBy: [String]?
    var hasNewAcceptance: Bool?
    var hasNewRequest: Bool?
    var reportedUsers: [String]?
    var bookmarkedMeetups: [String]?
    var interests: [Tag]?
    
    
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
        self.hasUnreadMessages = false
        self.reportedUsers = []
        self.bookmarkedMeetups = []
        self.interests = []
    }
    
    init(
        userId: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        photoURL: String? = nil,
        createdMeetups: [String]? = [],
        conversations: [String]? = [],
        homeCountry: String? = nil,
        age: String? = nil,
        bio: String? = nil,
        interests: [Tag]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.photoURL = photoURL
        self.dateCreated = Date()
        self.rsvpMeetups = []
        self.rsvpRequests = []
        self.createdMeetups = []
        self.conversations = []
        self.homeCountry = homeCountry
        self.age = age
        self.bio = bio
        self.hasUnreadMessages = false
        self.blockedUsers = []
        self.blockedBy = []
        self.hasNewAcceptance = false
        self.hasNewRequest = false
        self.reportedUsers = []
        self.bookmarkedMeetups = []
        self.interests = interests
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
        case hasUnreadMessages = "has_unread_messages"
        case blockedUsers = "blocked_users"
        case blockedBy = "blocked_by"
        case hasNewAcceptance = "has_new_acceptance"
        case hasNewRequest = "has_new_request"
        case reportedUsers = "reported_users"
        case bookmarkedMeetups = "bookmarked_meetups"
        case interests = "interests"
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
        self.hasUnreadMessages = try container.decodeIfPresent(Bool.self, forKey: .hasUnreadMessages)
        self.blockedUsers = try container.decodeIfPresent([String].self, forKey: .blockedUsers)
        self.blockedBy = try container.decodeIfPresent([String].self, forKey: .blockedBy)
        self.hasNewAcceptance = try container.decodeIfPresent(Bool.self, forKey: .hasNewAcceptance)
        self.hasNewRequest = try container.decodeIfPresent(Bool.self, forKey: .hasNewRequest)
        self.reportedUsers = try container.decodeIfPresent([String].self, forKey: .reportedUsers)
        self.bookmarkedMeetups = try container.decodeIfPresent([String].self, forKey: .bookmarkedMeetups)
        self.interests = try container.decodeIfPresent([Tag].self, forKey: .interests)
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
        try container.encodeIfPresent(self.hasUnreadMessages, forKey: .hasUnreadMessages)
        try container.encodeIfPresent(self.blockedUsers, forKey: .blockedUsers)
        try container.encodeIfPresent(self.blockedBy, forKey: .blockedBy)
        try container.encodeIfPresent(self.hasNewAcceptance, forKey: .hasNewAcceptance)
        try container.encodeIfPresent(self.hasNewRequest, forKey: .hasNewRequest)
        try container.encodeIfPresent(self.reportedUsers, forKey: .reportedUsers)
        try container.encodeIfPresent(self.bookmarkedMeetups, forKey: .bookmarkedMeetups)
        try container.encodeIfPresent(self.interests, forKey: .interests)
    }
}



