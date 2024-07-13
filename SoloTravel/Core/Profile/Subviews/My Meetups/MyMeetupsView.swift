//
//  MyMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct MyMeetupsView: View {
    @StateObject private var viewModel = MyMeetupsViewModel()
    var user: DBUser
    
    var body: some View {
        NavigationStack {
            VStack {
                if (viewModel.meetups.count > 0 || user.createdMeetups?.count ?? 0 > 0) {
                    ForEach(viewModel.meetups) { meetup in
                        NavigationLink {
                            MyMeetupView(meetup: meetup)
                        } label: {
                            MyOwnMeetupView(meetup: meetup)
                                .overlay(Button {
                                        Task { try await viewModel.deleteMeetup(meetupId: meetup.id) }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }.padding(), alignment: .topTrailing)
                        }
                    }
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
            .onAppear {
                Task {
                    try await viewModel.loadMeetups(userId: user.userId)
                }
            }
        }
        
        
    }
}

#Preview {
    MyMeetupsView(user: DBUser(userId: "123", email: "maxroberts2003@gmail.com", firstName: "Max", lastName: "Roberts", dateCreated: Date(), rsvpMeetups: [], createdMeetups: [], conversations: [], homeCountry: "United States"))
}
