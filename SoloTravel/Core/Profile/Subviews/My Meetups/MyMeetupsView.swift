//
//  MyMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct MyMeetupsView: View {
    @StateObject private var viewModel = MyMeetupsViewModel()
    @State private var isErrorAlertPresented = false
    @State private var isConfirmDeleteMeetupAlertPresented = false
    @State private var selectedMeetup: Meetup? = nil
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
                                        Task {
                                            isConfirmDeleteMeetupAlertPresented = true
                                            selectedMeetup = meetup
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }.padding(), alignment: .topTrailing)
                        }
                    }
                    
                } else {
                    Text("You haven't created any meetups yet.")
                        .frame(width: 400)
                    
                    NavigationLink {
                        MeetupCreationView()
                    } label: {
                        Text("Create a Meetup")
                            .foregroundStyle(.white)
                            .padding(.horizontal, 50)
                            .frame(width: 300, height: 45)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                Spacer()
                    //.background(.yellow)
            }
            //.background(.yellow)
            .navigationTitle("My Meetups")
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadMeetups(userId: user.userId)
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $isConfirmDeleteMeetupAlertPresented, content: {
                Alert(title: Text("Delete Meetup"), message: Text("Are you sure you want to delete this meetup?"), primaryButton: .destructive(Text("Confirm")) {
                    Task {
                        do {
                            try await viewModel.deleteMeetup(meetupId: selectedMeetup?.id ?? "")
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }
                }, secondaryButton: .cancel())
            })
        }
    }
}
                   

#Preview {
    MyMeetupsView(user: DBUser(userId: "123", email: "maxroberts2003@gmail.com", firstName: "Max", lastName: "Roberts", dateCreated: Date(), rsvpMeetups: [], createdMeetups: [], conversations: [], homeCountry: "United States"))
}
