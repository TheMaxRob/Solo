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
                    .foregroundStyle(.black)
                    .font(.headline)
                    .fontWeight(meetup.hasNewMember ?? false ? .bold : .regular)
                Text("\(formatDayAndTime(date: meetup.meetTime ?? Date()))")
                    .fontWeight(meetup.hasNewMember ?? false ? .bold : .regular)
                    .foregroundStyle(.black)
                    .font(.footnote)
                Text(((meetup.country?.isEmpty) == nil) ? "\(meetup.city ?? "") \(meetup.country ?? "")" : "\(meetup.city ?? "")")
                    .fontWeight(meetup.hasNewMember ?? false ? .bold : .regular)
                    .font(.footnote)
                    .foregroundStyle(.black)
                if meetup.hasNewMember ?? false {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)

                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical)
            .frame(width: 350)
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
    MyOwnMeetupView(meetup: Meetup(title: "Title", description: "description", meetTime: Date(), city: "Paris", country: "France", createdDate: Date(), organizerId: "organizerId", meetSpot: "Spot", attendees: [], pendingUsers: [], imageURL: ""))
}
