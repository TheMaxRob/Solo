//
//  MeetupManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/4/24.
//

import Foundation
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
 
    func fetchMeetups(city: String, completion: @escaping ([Meetup]) -> Void) async throws {
        let meetupsRef = db.collection("meetups")
        meetupsRef
            .whereField("meetups", arrayContains: city)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No meetups found.")
                    return
                }
                let meetups = documents.compactMap { document -> Meetup? in
                    try? document.data(as: Meetup.self)
                }
                completion(meetups)
            }
    }
}
