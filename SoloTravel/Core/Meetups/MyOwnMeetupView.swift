//
//  MeetupNoPictureView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/9/24.
//

import SwiftUI

struct MyOwnMeetupView: View {
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(String(describing: meetup.title))")
                    .font(.headline)
                Text("\(formatDayAndTime(date: meetup.meetTime ?? Date()))")
            }
            .padding()
            .frame(width: 400)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10, x: 3, y: 5)
        }
    }
}
    
private func formatDayAndTime(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"

    return formatter.string(from: date)
}

#Preview {
    MeetupView(meetup: Meetup(title: "Title", description: "description", meetTime: Date(), city: "Paris", country: "France", createdDate: Date(), organizerId: "organizerId", meetSpot: "Spot", attendees: [], pendingUsers: []))
}
