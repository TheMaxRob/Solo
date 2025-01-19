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
    // private let db = Firestore.firestore()
    private let userCollection = Firestore.firestore().collection("users")
    private let meetupsCollection = Firestore.firestore().collection("meetups")
    private let meetupIndexCollection = Firestore.firestore().collection("meetup_index")
    
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
    
    
    func getMeetupRef(meetupId: String) async throws -> DocumentReference? {
            let meetupRef = meetupsCollection.document(meetupId)
            return meetupRef
    }
    
    
    func addMeetup(meetup: Meetup) async throws {
        do {
            print("meetup received by addMeetup in MeetupManager: \(meetup)")

            // Reference to the meetups collection
            let meetupRef = meetupsCollection.document(meetup.id)

            // Encode the meetup object
            let meetupData = try encoder.encode(meetup)
            print("meetupData encoded: \(meetup)")

            // Add the meetup data to the meetups collection
            try await meetupRef.setData(meetupData)

        } catch {
            print("Error adding meetup: \(error)")
            throw error
        }
    }

    func fetchMeetups(start: Date, end: Date) async throws -> [Meetup] {
        print("fetchMeetups called in Manager")
        do {
            // Query the database for meetups within the specified date range
            let snapshot = try await meetupsCollection
                .whereField(Meetup.CodingKeys.meetTime.rawValue, isGreaterThanOrEqualTo: start)
                .whereField(Meetup.CodingKeys.meetTime.rawValue, isLessThanOrEqualTo: end)
                .getDocuments()

            // Decode the filtered meetups
            let meetups: [Meetup] = try snapshot.documents.compactMap { document in
                return try document.data(as: Meetup.self)
            }
            //print("returning meetups: \(meetups)")
            return meetups
        } catch {
            print("Error fetching meetups: \(error)")
            throw error 
        }
    }
    
    
    func fetchMeetup(meetupId: String) async throws -> Meetup? {
        print("fetchMeetup called in Manager")
        do {
            let document = try await meetupsCollection.document(meetupId).getDocument()
            
            guard document.exists else {
                print("Meetup with ID \(meetupId) does not exist.")
                return nil
            }

            let meetup = try document.data(as: Meetup.self)
            return meetup
        } catch {
            print("Error fetching meetup with ID \(meetupId): \(error)")
            throw error
        }
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

    
    
    func getMeetup(meetupId: String) async throws -> Meetup? {
        print("getMeetupId: \(meetupId)")
        let indexRef = meetupIndexCollection.document(meetupId)
        let indexSnapshot = try await indexRef.getDocument()
        if let data = indexSnapshot.data() {
            if let country = data["country"] as? String,
               let city = data["city"] as? String {
                let snapshot = try await meetupsCollection.document(country).collection(city).document(meetupId).getDocument()
                if let dict = snapshot.data() {
                    if let meetup = try? decoder.decode(Meetup.self, from: dict) {
                        return meetup
                    } else {
                        print("Error decodign meetup.")
                    }
                } else {
                    print("Error fetching dictionary info for meetup.")
                }
            }
        }
        print("An error occurred while fetching meetup.")
        return nil
    }
    
    
    func acceptUserToMeetup(meetupId: String, userId: String) async throws {
            print("acceptUserToMeetup")
        
            // Move user from pending to accepted
            if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
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
            let userRef = userCollection.document(userId)
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
            let meetupSnapshot = try await meetupRef.getDocument()
            if meetupSnapshot.exists {
                try await meetupRef.updateData([
                    "pending_users" : FieldValue.arrayRemove([userId]),
                ])
            } else {
                print("meetupSnapshot does not exist – declineUserToMeetup()")
            }
        }
        
        let userRef = userCollection.document(userId)
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
            let meetupSnapshot = try await meetupRef.getDocument()
            if meetupSnapshot.exists {
                try await meetupRef.updateData([
                    "attendees" : FieldValue.arrayRemove([userId])
                ])
            } else {
                print("meetupSnapshot does not exist – removeUserFromMeetup")
            }
        }
        
        let userRef = userCollection.document(userId)
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
            let snapshot = try await meetupRef.getDocument()
            if snapshot.exists {
                try await meetupRef.updateData([
                    Meetup.CodingKeys.pendingUsers.rawValue : FieldValue.arrayUnion([userId]),
                    "has_new_member" : true
                ])
                
                let organizerId = snapshot.data()?[Meetup.CodingKeys.organizerId.rawValue] as? String
                
                // Inform user that they have a new request
                if (organizerId != nil) {
                    let userRef = userCollection.document(organizerId ?? "")
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
            try await meetupIndexCollection.document(meetupId).delete()
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
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
        if let meetupRef = try await getMeetupRef(meetupId: meetupId) {
            let snapshot = try await meetupRef.getDocument()
            if snapshot.exists {
                try await meetupRef.updateData([
                    "has_new_member" : false
                ])
                print("has_new_member set to false")
                
                let userRef = userCollection.document(userId)
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
    
    
    func deleteExpiredMeetups() async throws {
        let db = Firestore.firestore()
        let meetupsRef = db.collection("meetups")
        
        // Get the current date and time
        let now = Date()
        
        do {
            // Asynchronously fetch meetups where `meetTime` is in the past
            let snapshot = try await meetupsRef.whereField("meet_time", isLessThan: now).getDocuments()
            
            // Delete each expired meetup
            for document in snapshot.documents {
                let docID = document.documentID
                try await meetupsRef.document(docID).delete()
                print("Successfully deleted expired meetup with ID: \(docID)")
            }
        } catch {
            print("Error fetching or deleting documents: \(error)")
            throw error
        }
    }

}
