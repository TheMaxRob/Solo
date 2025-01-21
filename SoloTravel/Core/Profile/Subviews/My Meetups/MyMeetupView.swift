//
//  MyMeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI
import MapboxMaps


struct MyMeetupView: View {
    
    var meetup: Meetup
    @EnvironmentObject private var userStateManager: UserStateManager
    @StateObject var viewModel = MyMeetupViewModel()
    @State private var isErrorAlertPresented = false
    @State private var isRemoveUserAlertPresented = false
    @State private var selectedUserForRemoval: DBUser? = nil
    
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
                                .foregroundStyle(viewModel.isShowingAttendeesView ? Color(.systemBackground) : .gray)
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
                                .foregroundStyle(viewModel.isShowingAttendeesView ? Color(.systemBackground) : .gray)
                        }
                    }
                }
                
                
                if viewModel.isShowingAttendeesView {
                    if viewModel.attendees.count > 0 {
                        ScrollView {
                            ForEach(viewModel.attendees) { attendee in
                                AcceptedUserCellView(viewModel: viewModel,  meetupId: meetup.id, profileUser: attendee)
                                    .overlay(Button {
                                        Task {
                                            isRemoveUserAlertPresented = true
                                            selectedUserForRemoval = attendee
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
                            PendingUserCellView(viewModel: viewModel, meetupId: meetup.id, profileUser: attendee)
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
                print("appear mymeetupview")
                    Task {
                        do {
                            // Clear arrays before reloading to prevent duplication
                            viewModel.attendees.removeAll()
                            viewModel.pendingUsers.removeAll()

                            try await viewModel.setNoNewMembers(meetupId: meetup.id, userId: userStateManager.currentUser?.userId ?? "")
                            try await viewModel.loadAttendees(userIds: meetup.attendees ?? [])
                            try await viewModel.loadPendingUsers(userIds: meetup.pendingUsers ?? [])
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }

            }
            .onDisappear {
                Task { try await userStateManager.refreshUser() }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $isRemoveUserAlertPresented, content: {
                Alert(title: Text("Remove User"), message: Text("Are you sure you want to remove this user?"),
                      primaryButton: .destructive(Text("Confirm"), action: {
                    Task {
                        do {
                            try await viewModel.removeUser(meetupId: meetup.id, userId: selectedUserForRemoval?.userId ?? "")
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }    
                }), secondaryButton: .cancel()
                )
            })
        }
    }
}

#Preview {
    MyMeetupView(meetup: Meetup(title: "Title", description: "description", meetTime: Date(), city: "Paris", createdDate: Date(), organizerId: "organizerId", location: CLLocationCoordinate2D(), attendees: [], pendingUsers: [], imageURL: ""))
}


struct PendingUserCellView: View {
    
    var viewModel: MyMeetupViewModel
    @EnvironmentObject private var userStateManager: UserStateManager
    var meetupId: String
    var profileUser: DBUser
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                NavigationLink {
                    PublicProfileView(profileUser: profileUser)
                } label: {
                    UserPFPView(photoURL: profileUser.photoURL ?? "")
                }
                Text("\(profileUser.firstName ?? "") \(profileUser.lastName ?? "")")
                    .bold()
                    .font(.title2)

                HStack {
                    Button(action: {
                        Task {
                            print("Accept Button Pressed")
                            try await viewModel.acceptRSVP(meetupId: meetupId, userId: profileUser.userId)
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
                            try await viewModel.declineRSVP(meetupId: meetupId, userId: userStateManager.currentUser?.userId ?? "")
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
                try await viewModel.loadImage(from: userStateManager.currentUser?.photoURL ?? "", userStateManager: userStateManager)
            }
        }
    }
}


struct AcceptedUserCellView: View {
    
    var viewModel: MyMeetupViewModel
    @EnvironmentObject private var userStateManager: UserStateManager
    var meetupId: String
    var profileUser: DBUser
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .center) {
                    NavigationLink {
                        PublicProfileView(profileUser: profileUser)
                    } label: {
                        UserPFPView(photoURL: profileUser.photoURL ?? "")
                    }
                    Text("\(profileUser.firstName ?? "") \(profileUser.lastName ?? "")")
                        .bold()
                        .font(.title2)
                }
            }
            .frame(width: 345, height: 130)
            //.background(.yellow)
            .shadow(radius: 5, x: 3, y: 3)
            .onAppear {
                Task { try await viewModel.loadImage(from: userStateManager.currentUser?.photoURL ?? "", userStateManager: userStateManager) }
            }
            
        }
    }
}

#Preview(body: {
    AcceptedUserCellView(viewModel: MyMeetupViewModel(), meetupId: "", profileUser: DBUser(userId: ""))
})
