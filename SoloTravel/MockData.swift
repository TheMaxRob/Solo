//
//  MockData.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import Foundation


struct MockMeetups {
    
    static let mockMeetup1 = Meetup(id: "1234", title: "Walking Tour", description: "Come walk around the city with me! We'll go to three attractions.", meetTime: Date(), city: "Sevilla", createdDate: Date(), organizerId: "12345", meetSpot: "City Center Monument")
    
    static let mockMeetup2 = Meetup(id: "123", title: "Hiking", description: "Let's go out into the forest and hike for a few hours! Planning on a bigger group.", meetTime: Date(), city: "Heidelberg", createdDate: Date(), organizerId: "123456", meetSpot: "Black Forest")
    
    static let mockMeetup3 = Meetup(id: "12", title: "Dinner", description: "Walk around the city and find a nice spot to relax and have dinner.", meetTime: Date(), city: "Paris", createdDate: Date(), organizerId: "1234567", meetSpot: "Old Town")
    
    static let mockMeetups = [mockMeetup1, mockMeetup2, mockMeetup3]
    
    // static let mockConversations = 
}
