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
        print("addMeetup in Manager called!")
        let cityRef = db.collection("meetups").document(meetup.city)
        
        let documentSnapshot = try await cityRef.getDocument()
        
        if documentSnapshot.exists {
            try await cityRef.updateData([
                "meetups": FieldValue.arrayUnion([try encoder.encode(meetup)])
            ])
        } else {
            try await cityRef.setData([
                "meetups": [try encoder.encode(meetup)]
            ])
        }
    }
    
    func fetchMeetups(city: String) async throws -> [Meetup] {
      let docRef = db.collection("meetups").document(city)
      let documentSnapshot = try await docRef.getDocument()
        guard let data = documentSnapshot.data() else {
            print("Data does not exist")
            return []
        }

        guard let meetups = data["meetups"] else {
            print("meetups not fetched from data.")
            return []
        }
        let convertedMeetups = convertToMeetupObjects(meetupDicts: meetups as! [[String : Any]])
        return convertedMeetups
    }
    
    private func convertToMeetupObjects(meetupDicts: [[String: Any]]) -> [Meetup] {
        var meetups = [Meetup]()
        
        
        // Manually decoding because this is making me pull my hair out
        for dict in meetupDicts {
            guard
                let id = dict["id"] as? String,
                let title = dict["title"] as? String,
                let description = dict["description"] as? String?,
                let city = dict["city"] as? String,
                let organizerId = dict["organizerId"] as? String,
                let meetSpot = dict["meetSpot"] as? String,
                let createdDateTimestamp = dict["createdDate"] as? Timestamp,
                let meetTimeTimestamp = dict["meetTime"] as? Timestamp
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
                id: id,
                title: title,
                description: description,
                meetTime: meetTime,
                city: city,
                createdDate: createdDate,
                organizerId: organizerId,
                meetSpot: meetSpot
            )
            
            meetups.append(meetup)
        }
        return meetups
    }


}
