//
//  MyMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct MyMeetupsView: View {
    
    var user: DBUser
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .background(.yellow)
                if (user.createdMeetups?.count ?? 0 > 0) {
                    List {
                        ForEach(user.createdMeetups ?? []) { meetup in
                            MeetupView(meetup: meetup)
                        }
                    }
                    .background(.yellow)
                    
                } else {
                    Text("You haven't created any meetups yet.")
                        .frame(width: 400)
                        .background(.yellow)
                    
                    NavigationLink {
                        MeetupCreationView()
                    } label: {
                        Text("Create a Meetup")
                            .foregroundStyle(.white)
                            .frame(width: 300)
                            .padding()
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
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
    MyMeetupsView(user: DBUser(userId: "123", email: "maxroberts2003@gmail.com", firstName: "Max", lastName: "Roberts", dateCreated: Date(), rsvpMeetups: [], createdMeetups: [], conversations: [], homeCountry: "United States", birthDate: Date()))
}
