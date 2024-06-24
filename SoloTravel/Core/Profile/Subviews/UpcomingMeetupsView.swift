//
//  UpcomingMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct UpcomingMeetupsView: View {
    var user: DBUser
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .background(.yellow)
                if (user.rsvpMeetups?.count ?? 0 > 0) {
                    List {
                        ForEach(user.rsvpMeetups ?? []) { meetup in
                            MeetupView(meetup: meetup)
                        }
                    }
                    .background(.yellow)
                    
                } else {
                    Text("You have no upcoming meetups. Bummer!")
                        .frame(width: 400)
                        .background(.yellow)
                }
                Spacer()
                    .background(.yellow)
            }
            .background(.yellow)
            .navigationTitle("My Meetups")  
        }
    }
}

#Preview {
    UpcomingMeetupsView(user: DBUser(userId: "123", firstName: "Max", lastName: "Roberts"))
}
