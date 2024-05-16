//
//  MeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

struct Meetup: Identifiable, Codable, Hashable {
    let title: String
    let description: String
    let meetTime: Date
    let createdDate: Date
    let organizer: DBUser
    let meetSpot: String
}

struct MeetupView: View {
    
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            Text("\(meetup.title)")
        }
        
    }
}

#Preview {
    MeetupView(meetup: MockMeetups.mockMeetups[0])
}
