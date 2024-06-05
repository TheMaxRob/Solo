//
//  MockData.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import Foundation


struct MockMeetups {
    
    static let mockMeetup1 = Meetup(title: "Walking Tour", description: "Come walk around the city with me! We'll go to three attractions.", meetTime: Date(), city: "Sevilla", createdDate: Date(), organizer: DBUser(userId: "12345", email: "hello@mock.com"), meetSpot: "City Center Monument")
    
    static let mockMeetup2 = Meetup(title: "Hiking", description: "Let's go out into the forest and hike for a few hours! Planning on a bigger group.", meetTime: Date(), city: "Heidelberg", createdDate: Date(), organizer: DBUser(userId: "123456", email: "hello2@mock.com"), meetSpot: "Black Forest")
    
    static let mockMeetup3 = Meetup(title: "Dinner", description: "Walk around the city and find a nice spot to relax and have dinner.", meetTime: Date(), city: "Paris", createdDate: Date(), organizer: DBUser(userId: "1234567", email: "hello3@mock.com"), meetSpot: "Old Town")
    
    static let mockMeetups = [mockMeetup1, mockMeetup2, mockMeetup3]
    
    // static let mockConversations = 
}
