import SwiftUI

struct MeetupDetailsView: View {
    
    @StateObject private var viewModel = MeetupDetailsViewModel()
    @State private var isConfirmingUnRSVP = false // Confirmation alert
    @State private var isConfirmingUnbookmark = false // Confirmation alert for bookmark
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
