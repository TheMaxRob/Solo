// MeetupDetailsView.swift

import SwiftUI

struct MeetupDetailsView: View {
    
    @StateObject private var viewModel = MeetupDetailsViewModel()
    @State private var isConfirmingUnRSVP = false
    @State private var isConfirmingUnbookmark = false
    @State private var isRSVPed = false
    @State private var isBookmarked = false
    var meetup: Meetup
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isErrorAlertPresented = false
    @EnvironmentObject private var userStateManager: UserStateManager
    
    var body: some View {
        NavigationStack {
            VStack {
                if let meetupImage = viewModel.image {
                    Image(uiImage: meetupImage)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 200)
                        .clipped() // Crop excess content
//                        .overlay(
//                            Rectangle()
//                                .fill(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
//                                        startPoint: .bottom,
//                                        endPoint: .top
//                                    )
//                                )
//                        )
                }
                VStack {
                    Text("\(meetup.title)")
                        .font(.title)
                        .bold()
                        .padding()
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text("Created by: \(viewModel.host?.firstName ?? "Unknown") \(viewModel.host?.lastName ?? "")")
                        .padding(.bottom)
                    
                    Text("\(meetup.location)")
                        .bold()
                        .font(.subheadline)
                    
                    Text("\(meetup.meetTime?.formatted(date: .abbreviated, time: .shortened) ?? Date().formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .padding(.bottom)
                        .bold()
                    
                    
                    // Tags Section
                    if let tags = meetup.tags, !tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .padding(.top)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(tags, id: \.self) { tag in
                                    Text("\(tag)")
                                        .frame(width: 100, height: 30) // Fixed width and height
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .font(.footnote)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }


                    
                    // Who's Going Section
                    HStack {
                            // Host
                            VStack {
                                Text("Host")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                NavigationLink {
                                    PublicProfileView(profileUser: viewModel.host)
                                } label: {
                                    UserPFPView(photoURL: viewModel.host?.photoURL ?? "")
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                            }
                            
                            Spacer()
                            
                            // Attendees
                            VStack {
                                Text("Attendees")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                NavigationLink {
                                    AttendeesListView(attendees: viewModel.attendeeImages)
                                } label: {
                                    HStack {
                                        ForEach(meetup.attendees ?? [], id: \.self) { attendeeId in
                                            if let image = viewModel.attendeeImages[attendeeId] {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            } else {
                                                ProgressView()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        if let attendees = meetup.attendees, attendees.count > 3 {
                                            Text("+\(attendees.count - 3)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.leading, 4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()

                    
                    
                    Text("\(meetup.description ?? "")")
                        .font(.footnote)
                        .padding()
                    
                    if userStateManager.currentUser?.userId != meetup.organizerId {
                        HStack {
                            Button {
                                Task {
                                    // Handle User Blocks
                                    if (userStateManager.currentUser?.blockedUsers?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                        alertMessage = "You have blocked this user."
                                        showAlert = true
                                    } else if (userStateManager.currentUser?.blockedBy?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                        alertMessage = "You have been blocked by this user."
                                        showAlert = true
                                        
                                        // Handle RSVP
                                    } else if !isRSVPed {
                                        do {
                                            try await viewModel.requestRSVP(meetup: meetup, userId: userStateManager.currentUser?.userId ?? "")
                                            withAnimation {
                                                isRSVPed = true
                                            }
                                            try await userStateManager.refreshUser()
                                        } catch {
                                            print("Error requesting RSVP")
                                        }
                                        
                                        // Show confirmation alert for un-RSVP
                                    } else {
                                        isConfirmingUnRSVP = true
                                    }
                                }
                            } label: {
                                if isRSVPed {
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 90, height: 45)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .transition(.opacity.combined(with: .scale))
                                } else if userStateManager.currentUser?.rsvpMeetups?.contains(where: { $0 == meetup.id }) == true || ((userStateManager.currentUser?.rsvpRequests?.contains(where: { $0 == meetup.id }) == true)) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                    }
                                    .frame(width: 90, height: 45)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Text("RSVP")
                                        .frame(width: 90, height: 45)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.green, lineWidth: 1)
                                        )
                                        .foregroundStyle(.green)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    if (userStateManager.currentUser?.blockedUsers?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                        alertMessage = "You have blocked this user."
                                        showAlert = true
                                    } else if (userStateManager.currentUser?.blockedBy?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                        alertMessage = "You have been blocked by this user."
                                        showAlert = true
                                    } else {
                                        print("create Conversation")
                                        viewModel.conversationId = try await viewModel.createConversation(with: meetup.organizerId ?? "", userId: userStateManager.currentUser?.userId ?? "")
                                    }
                                }
                            } label: {
                                Text("Message")
                                    .frame(width: 90, height: 45)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.blue, lineWidth: 1)
                                    )
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    
                }
                .overlay(alignment: .topTrailing, content: {
                    Button {
                        Task {
                            if isBookmarked {
                                // Show confirmation alert instead of immediately removing
                                isConfirmingUnbookmark = true
                            } else {
                                do {
                                    try await viewModel.bookmarkMeetup(userId: userStateManager.currentUser?.userId ?? "", meetupId: meetup.id)
                                    withAnimation {
                                        isBookmarked = true
                                    }
                                } catch {
                                    isErrorAlertPresented = true
                                }
                            }
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .padding()
                            .animation(.easeInOut, value: isBookmarked)
                    }
                })
                Spacer()
                    .navigationTitle("Meetup Details")
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
            .alert("Remove RSVP", isPresented: $isConfirmingUnRSVP) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.unrequest(meetupId: meetup.id, userId: userStateManager.currentUser?.userId ?? "")
                            withAnimation {
                                isRSVPed = false
                            }
                            try await userStateManager.refreshUser()
                        } catch {
                            print("Error removing RSVP request")
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to remove your RSVP request for this meetup?")
            }
            .alert("Remove Bookmark", isPresented: $isConfirmingUnbookmark) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.removeBookmark(userId: userStateManager.currentUser?.userId ?? "", meetupId: meetup.id)
                            withAnimation {
                                isBookmarked = false
                            }
                        } catch {
                            print("Error removing bookmark")
                            isErrorAlertPresented = true
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to remove this meetup from your bookmarks?")
            }
            .padding(.horizontal, 50)
            .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                ChatView(conversationId: viewModel.conversationId ?? "")
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.getHost(userId: meetup.organizerId ?? "")
                        try await viewModel.loadImage(from: meetup.imageURL ?? "", userStateManager: userStateManager)
                        try await viewModel.preloadAttendeeImages(attendees: meetup.attendees ?? [], userStateManager: userStateManager)
                        
                        isRSVPed = userStateManager.currentUser?.rsvpRequests?.contains(meetup.id) ?? false
                        isBookmarked = userStateManager.currentUser?.bookmarkedMeetups?.contains(meetup.id) ?? false
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
        }
    }
}

struct AttendeesListView: View {
    var attendees: [String: UIImage]

    var body: some View {
        List(attendees.keys.sorted(), id: \.self) { attendeeId in
            NavigationLink {
                PublicProfileView(profileUserId: attendeeId, profileImage: attendees[attendeeId])
            } label: {
                HStack {
                    if let image = attendees[attendeeId] {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    Text(attendeeId)
                }
            }
        }
        .navigationTitle("Attendees")
    }
}

