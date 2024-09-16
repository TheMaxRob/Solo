//
//  MyMeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI




struct MyMeetupView: View {
    
    var meetup: Meetup
    @StateObject var viewModel = MyMeetupViewModel()
    @State private var isErrorAlertPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Toggle Buttons
                HStack(spacing: 0) {
                    Button(action: {
                        viewModel.isShowingAttendeesView = true
                        viewModel.isShowingPendingView = false
                    }) {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10)
                                .frame(width: 155, height: 30)
                                .foregroundStyle(viewModel.isShowingAttendeesView ? .gray.opacity(0.7) : .gray.opacity(0.4))
                            Text("Accepted")
                                .foregroundStyle(viewModel.isShowingAttendeesView ? .black : .gray)
                        }
                    }
                    Button {
                        viewModel.isShowingAttendeesView = false
                        viewModel.isShowingPendingView = true
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10)
                                .frame(width: 155, height: 30)
                                .foregroundStyle(viewModel.isShowingPendingView ? .gray.opacity(0.7) : .gray.opacity(0.4))
                            Text("Requests")
                                .foregroundStyle(viewModel.isShowingPendingView ? .black : .gray)
                        }
                    }
                }
                
                
                if viewModel.isShowingAttendeesView {
                    if viewModel.attendees.count > 0 {
                        ScrollView {
                            ForEach(viewModel.attendees) { attendee in
                                AcceptedUserCellView(viewModel: viewModel, user: attendee, meetupId: meetup.id)
                                    .overlay(Button {
                                        Task {
                                            try await viewModel.removeUser(meetupId: meetup.id, userId: attendee.userId)
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                    }
                                    .padding(.horizontal, 5)
                                    .buttonStyle(BorderlessButtonStyle()),
                                    alignment: .topTrailing)
                                
                                Divider()
                                    .padding(.top, -15)
                            }
                            Spacer()
                        }
                    } else {
                        Spacer()
                        Text("No one is coming yet, bummer.")
                        Spacer()
                    }
                } else if viewModel.isShowingPendingView {
                    if viewModel.pendingUsers.count > 0 {
                        ForEach(viewModel.pendingUsers) { attendee in
                            PendingUserCellView(viewModel: viewModel, user: attendee, meetupId: meetup.id)
                        }
                        
                    } else {
                        Spacer()
                        Text("No pending attendees.")
                        Spacer()
                    }
                    
                    Spacer()
                }
                   
            }
            .frame(width: 350)
            // .background(Color.yellow.edgesIgnoringSafeArea(.all))
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadCurrentUser()
                        try await viewModel.setNoNewMembers(meetupId: meetup.id, userId: viewModel.user?.userId ?? "")
                        try await viewModel.loadAttendees(userIds: meetup.attendees ?? [])
                        try await viewModel.loadPendingUsers(userIds: meetup.pendingUsers ?? [])
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    MyMeetupView(meetup: Meetup(
        title: "Title",
        description: "description",
        meetTime: Date(),
        city: "Paris",
        country: "France",
        createdDate: Date(),
        organizerId: "organizerId",
        meetSpot: "Spot",
        attendees: [],
        pendingUsers: [],
        imageURL: ""
    ))
}


struct PendingUserCellView: View {
    
    var viewModel: MyMeetupViewModel
    var user: DBUser
    var meetupId: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                NavigationLink {
                    PublicProfileView(userId: user.userId)
                } label: {
                    UserPFPView(user: user)
                }
                Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.black)
                HStack {
                    Button(action: {
                        Task {
                            print("Accept Button Pressed")
                            try await viewModel.acceptRSVP(meetupId: meetupId, userId: user.userId)
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.green.opacity(0.5))
                                .frame(width: 110, height: 30)
                            Text("Accept")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: {
                        Task {
                            print("Decline Button Pressed")
                            try await viewModel.declineRSVP(meetupId: meetupId, userId: user.userId)
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.red.opacity(0.5))
                                .frame(width: 110, height: 30)
                            Text("Reject")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding()
        .frame(width: 345, height: 180)
        //.background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10, x: 3, y: 5)
        .onAppear {
            Task {
                try await viewModel.loadImage(from: user.photoURL ?? "")
            }
        }
    }
}


struct AcceptedUserCellView: View {
    
    var viewModel: MyMeetupViewModel
    var user: DBUser
    var meetupId: String
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .center) {
                    NavigationLink {
                        PublicProfileView(userId: user.userId)
                    } label: {
                        UserPFPView(user: user)
                    }
                    Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.black)
                }
            }
            .frame(width: 345, height: 130)
            //.background(.yellow)
            .shadow(radius: 5, x: 3, y: 3)
            .onAppear {
                Task { try await viewModel.loadImage(from: user.photoURL ?? "") }
            }
            
        }
    }
}

#Preview(body: {
    AcceptedUserCellView(viewModel: MyMeetupViewModel(), user: DBUser(userId: ""), meetupId: "")
})
