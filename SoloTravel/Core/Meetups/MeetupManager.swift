//
//  MeetupManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/4/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MeetupManager {
    static let shared = MeetupManager()
    private let db = Firestore.firestore()
    
    static let cities = [
        "Barcelona, Spain", "Florence, Italy", "Lisbon, Portugal", "London, United Kingdom", "Madrid, Spain", "Nice, France", "Paris, Frace", "Porto, Lisbon,", "Rome, Italy", "Sevilla, Spain", "Valencia, Spain", "Venice, Italy"
    ]
    
    private init() { }
    
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
    
    
    func addMeetup(meetup: Meetup) async throws {
        print("meetup received by addMeetup in MeetupManager: \(meetup)")
        let countryRef = db.collection("meetups").document(meetup.country ?? "")
        let meetupRef = countryRef.collection(meetup.city ?? "").document(meetup.id)
        let meetupData = try encoder.encode(meetup)
        print("meetupData encoded: \(meetup)")
        
        try await meetupRef.setData(meetupData)
        
        let indexRef = db.collection("meetup_index").document(meetup.id)
        try await indexRef.setData([
            "country" : meetup.country ?? "",
            "city" : meetup.city ?? ""
        ])
    }
    
    
    func fetchMeetups(country: String, city: String) async throws -> [Meetup] {
        let docRef = db.collection("meetups").document(country).collection(city)
        let snapshot = try await docRef.getDocuments()
        do {
            let meetups: [Meetup] = try snapshot.documents.compactMap { document in
                return try document.data(as: Meetup.self)
            }
            return meetups
        } catch {
            print("Error decoding meetups: \(error)")
            return []
        }
//      let documentSnapshot = try await docRef.getDocument()
//        guard let data = documentSnapshot.data() else {
//            print("Data does not exist")
//            return []
//        }
//
//        guard let meetups = data["meetups"] else {
//            print("meetups not fetched from data.")
//            return []
//        }
//        let convertedMeetups = convertToMeetupObjects(meetupDicts: meetups as! [[String : Any]])
//        return convertedMeetups
    }
    
    
    func filterMeetupsByTimeFrame(meetups: [Meetup], start: Date, end: Date) -> [Meetup] {
        var filteredMeetups: [Meetup] = []
        for meetup in meetups {
            print("Start: \(start)")
            print("meetTime: \(meetup.meetTime ?? Date.distantFuture)")
            print("end: \(end)")
            if meetup.meetTime ?? Date.distantFuture  >= start && meetup.meetTime ?? Date.distantFuture <= end {
                filteredMeetups.append(meetup)
            }
        }
        return filteredMeetups
    }

    
    private func convertToMeetupObjects(meetupDicts: [[String: Any]]) -> [Meetup] {
        var meetups = [Meetup]()
        
        
        // Manually decoding because this is making me pull my hair out
        for dict in meetupDicts {
            guard
                let title = dict["title"] as? String,
                let description = dict["description"] as? String?,
                let city = dict["city"] as? String,
                let country = dict["country"] as? String,
                let organizerId = dict["organizerId"] as? String,
                let meetSpot = dict["meetSpot"] as? String,
                let createdDateTimestamp = dict["createdDate"] as? Timestamp,
                let meetTimeTimestamp = dict["meetTime"] as? Timestamp,
                let attendees = dict["attendees"] as? [String]?,
                let pendingUsers = dict["pending_users"] as? [String]?
            else {
                // Handle missing or incorrect data
                print("Data parsing error for dict: \(dict)")
                continue
            }
            
            // Convert FIRTimestamp to Date
            let createdDate = createdDateTimestamp.dateValue()
            let meetTime = meetTimeTimestamp.dateValue()
            
            // Initialize Meetup object
            let meetup = Meetup(
                title: title,
                description: description,
                meetTime: meetTime,
                city: city,
                country: country,
                createdDate: createdDate,
                organizerId: organizerId,
                meetSpot: meetSpot,
                attendees: attendees,
                pendingUsers: pendingUsers,
                imageURL: ""
            )
            
            meetups.append(meetup)
        }
        return meetups
    }
    
    func getMeetupRefByIndex(meetupId: String) async throws -> DocumentReference? {
        let indexRef = db.collection("meetup_index").document(meetupId)
        let indexSnapshot = try await indexRef.getDocument()
        if let indexData = indexSnapshot.data() {
            if let country = indexData["country"] as? String,
               let city = indexData["city"] as? String {
                return db.collection("meetups").document(country)
                    .collection(city).document(meetupId)
            } else {
                print("returned nil – country or city failed")
            }
        } else {
            print("returned nil – indexData failed")
        }
        return nil
    }

    
    
    func getMeetup(meetupId: String) async throws -> Meetup? {
        print("getMeetupId: \(meetupId)")
        let indexRef = db.collection("meetup_index").document(meetupId)
        let indexSnapshot = try await indexRef.getDocument()
        if let data = indexSnapshot.data() {
            if let country = data["country"] as? String,
               let city = data["city"] as? String {
                let snapshot = try await db.collection("meetups").document(country).collection(city).document(meetupId).getDocument()
                if let dict = snapshot.data() {
                    if let meetup = try? decoder.decode(Meetup.self, from: dict) {
                        return meetup
                    }
                    guard
                        let _ = dict["id"] as? String,
                        let title = dict["title"] as? String,
                        let description = dict["description"] as? String?,
                        let city = dict["city"] as? String,
                        let country = dict["country"] as? String,
                        let organizerId = dict["organizerId"] as? String,
                        let meetSpot = dict["meetSpot"] as? String,
                        let createdDateTimestamp = dict["createdDate"] as? Timestamp,
                        let meetTimeTimestamp = dict["meetTime"] as? Timestamp,
                        let attendees = dict["attendees"] as? [String]?,
                        let pendingUsers = dict["pending_users"] as? [String]?
                    else {
                        print("Data parsing error for dict: \(dict)")
                        return nil
                    }
                    let createdDate = createdDateTimestamp.dateValue()
                    let meetTime = meetTimeTimestamp.dateValue()
                    
                    let meetup = Meetup(
                        title: title,
                        description: description,
                        meetTime: meetTime,
                        city: city,
                        country: country,
                        createdDate: createdDate,
                        organizerId: organizerId,
                        meetSpot: meetSpot,
                        attendees: attendees,
                        pendingUsers: pendingUsers,
                        imageURL: ""
                    )
                    return meetup
            }
               
            
        }
        
        }
        else { return nil }
        return nil
    }
    
    
//    func getMeetupRef(meetupId: String) async throws -> DocumentReference? {
//        let ref = db.collection("meetupIndex").document(meetupId)
//        let snapshot = try await ref.getDocument()
//        
//        if let data = snapshot.data() {
//            do {
//                let country = data["country"] as? String
//                let city = data["city"] as? String
//                print("data exists for getMeetupRef")
//                return db.collection("meetups").document(country)
//                    .collection(city).document(meetupId)
//            } catch {
//                print("Error: \(error)")
//                return nil
//            }
//        }
//    }
    
    
    func acceptUserToMeetup(meetupId: String, userId: String) async throws {
            print("acceptUserToMeetup")
        
            // Move user from pending to accepted
            if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
                let meetupSnapshot = try await meetupRef.getDocument()
                if meetupSnapshot.exists {
                    try await meetupRef.updateData([
                        Meetup.CodingKeys.pendingUsers.rawValue : FieldValue.arrayRemove([userId]),
                        Meetup.CodingKeys.attendees.rawValue : FieldValue.arrayUnion([userId]),
                    ])
                } else {
                    print("meetupRef does not exist – acceptUserToMeetup()")
                }
            }
            
            // Move meetup from requested to upcoming
            let userRef = db.collection("users").document(userId)
            let userSnapshot = try await userRef.getDocument()
            if userSnapshot.exists {
                try await userRef.updateData([
                    DBUser.CodingKeys.rsvpRequests.rawValue : FieldValue.arrayRemove([meetupId]),
                    DBUser.CodingKeys.rsvpMeetups.rawValue : FieldValue.arrayUnion([meetupId]),
                    "has_new_acceptance" : true
                ])
            } else {
                print("userRef does not exist – acceptUserToMeetup()")
            }
        
        }


    
    
    func declineUserToMeetup(meetupId: String, userId: String) async throws {
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            let meetupSnapshot = try await meetupRef.getDocument()
            if meetupSnapshot.exists {
                try await meetupRef.updateData([
                    "pending_users" : FieldValue.arrayRemove([userId]),
                ])
            } else {
                print("meetupSnapshot does not exist – declineUserToMeetup()")
            }
        }
        
        let userRef = db.collection("users").document(userId)
        let userSnapshot = try await userRef.getDocument()
        if userSnapshot.exists {
            try await userRef.updateData([
                "rsvp_requests" : FieldValue.arrayRemove([meetupId])
            ])
        } else {
            print("userRef does not exist – declineUserToMeetup()")
        }
    }
    
    
    func removeUserFromMeetup(meetupId: String, userId: String) async throws {
        print("removeUserFromMeetup")
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            let meetupSnapshot = try await meetupRef.getDocument()
            if meetupSnapshot.exists {
                try await meetupRef.updateData([
                    "attendees" : FieldValue.arrayRemove([userId])
                ])
            } else {
                print("meetupSnapshot does not exist – removeUserFromMeetup")
            }
        }
        
        let userRef = db.collection("users").document(userId)
        let userSnapshot = try await userRef.getDocument()
        if userSnapshot.exists {
            try await userRef.updateData([
                "rsvp_meetups" : FieldValue.arrayRemove([meetupId])
            ])
        } else {
            print("userRef does not exist – removeUserFromMeetup() \(userId)")
        }
        
    }

    
    // Add a user to pending
    func addPendingUser(meetupId: String, userId: String) async throws {
        // Update meetup data
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            let snapshot = try await meetupRef.getDocument()
            if snapshot.exists {
                try await meetupRef.updateData([
                    Meetup.CodingKeys.pendingUsers.rawValue : FieldValue.arrayUnion([userId]),
                    "has_new_member" : true
                ])
                
                let organizerId = snapshot.data()?[Meetup.CodingKeys.organizerId.rawValue] as? String
                
                // Inform user that they have a new request
                if (organizerId != nil) {
                    let userRef = db.collection("users").document(organizerId ?? "")
                    let userSnapshot = try await userRef.getDocument()
                    if userSnapshot.exists {
                        try await userRef.updateData([
                            DBUser.CodingKeys.hasNewRequest.rawValue : true
                        ])
                    } else {
                        print("Could not find user document in addPendingUser")
                    }
                } else {
                    print("organizerId not found")
                }
            } else {
                print("Could not addPendingUser.")
            }
        }
        
        
        // Inform organizer that they have a new rsvp request
        
    }
    
    
    func deleteMeetup(meetupId: String) async throws {
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            try await db.collection("meetup_index").document(meetupId).delete()
            let snapshot = try await meetupRef.getDocument()
            if snapshot.exists {
                // remove meetupId from the "rsvp_meetups" field of all attending users
                if let attendeeIds = snapshot.data()?["attendees"] as? [String] {
                    for attendeeId in attendeeIds {
                        let attendeeRef = UserManager.shared.userDocument(userId: attendeeId)
                        let attendeeSnapshot = try await attendeeRef.getDocument()
                        if attendeeSnapshot.exists {
                            try await attendeeRef.updateData([
                                "rsvp_meetups" : FieldValue.arrayRemove([meetupId])
                            ])
                        }
                    }
                }
                
                // remove meetupId from the "rsvp_requests" of all pending users
                if let pendingUserIds = snapshot.data()?["pending_users"] as? [String] {
                    for pendingId in pendingUserIds {
                        let pendingRef = UserManager.shared.userDocument(userId: pendingId)
                        let pendingSnapshot = try await pendingRef.getDocument()
                        if pendingSnapshot.exists {
                            try await pendingRef.updateData([
                                "rsvp_requests" : FieldValue.arrayRemove([meetupId])
                            ])
                        }
                    }
                }
                
                
                // remove meetupId frmo the "created_meetups" of the organizer, whose id is found in "organizer_id" of the meetup document
                if let organizerId = snapshot.data()?["organizer_id"] as? String {
                    let organizerRef = UserManager.shared.userDocument(userId: organizerId)
                    let organizerSnapshot = try await organizerRef.getDocument()
                    if organizerSnapshot.exists {
                        try await organizerRef.updateData([
                            "created_meetups" : FieldValue.arrayRemove([meetupId])
                        ])
                    }
                    
                }
                
            }
            try await meetupRef.delete()
        }
        
    }
    
    func unRSVP(meetupId: String, userId: String) async throws {
        print("unRSVP. meetupId: \(meetupId) userId: \(userId)")
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            let meetupSnapshot = try await meetupRef.getDocument()
            if meetupSnapshot.exists {
                try await meetupRef.updateData([
                    "attendees" : FieldValue.arrayRemove([userId])
                ])
            }
        }
        
        let userRef = UserManager.shared.userDocument(userId: userId)
        let userSnapshot = try await userRef.getDocument()
        if userSnapshot.exists {
            try await userRef.updateData([
                "rsvp_meetups" : FieldValue.arrayRemove([meetupId])
            ])
        }
    }
    
    
    func unRequest(meetupId: String, userId: String) async throws {
        print("unRequest – meetupId: \(meetupId) userId: \(userId)")
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            let meetupSnapshot = try await meetupRef.getDocument()
            if meetupSnapshot.exists {
                try await meetupRef.updateData([
                    "pending_users" : FieldValue.arrayRemove([userId])
                ])
            }
        }
        
        let userRef = UserManager.shared.userDocument(userId: userId)
        let userSnapshot = try await userRef.getDocument()
        if userSnapshot.exists {
            try await userRef.updateData([
                "rsvp_requests" : FieldValue.arrayRemove([meetupId])
            ])
        }
    }
    
     
    // On host end – get rid of notifications
    func setNoNewMembers(meetupId: String, userId: String) async throws {
        if let meetupRef = try await getMeetupRefByIndex(meetupId: meetupId) {
            let snapshot = try await meetupRef.getDocument()
            if snapshot.exists {
                try await meetupRef.updateData([
                    "has_new_member" : false
                ])
                print("has_new_member set to false")
                
                let userRef = db.collection("users").document(userId)
                let userSnapshot = try await userRef.getDocument()
                if userSnapshot.exists {
                    try await userRef.updateData([
                        "has_new_request" : false
                    ])
                }
                
            } else {
                print("could not find meetup snapshot – setNoNewMembers")
            }
        } else {
            print("Could not fetch meetupRef – setNoNewMembers")
        }
    }
}
