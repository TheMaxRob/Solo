import SwiftUI

struct MeetupDetailsView: View {
    
    @StateObject private var viewModel = MeetupDetailsViewModel()
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
                        .scaledToFill()
                        .frame(minHeight: 400)
                }
                VStack {
                    Text("\(meetup.title)")
                        .font(.title)
                        .bold()
                        .padding()
                    
                    Text("Created by: \(viewModel.host?.firstName ?? "Unknown") \(viewModel.host?.lastName ?? "")")
                        .padding(.bottom)
                    
                    Text("Meet At \(meetup.meetSpot ?? "")")
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
                                    if (userStateManager.currentUser?.blockedUsers?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                        alertMessage = "You have blocked this user."
                                        showAlert = true
                                    } else if (userStateManager.currentUser?.blockedBy?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                        alertMessage = "You have been blocked by this user."
                                        showAlert = true
                                    } else {
                                        try await viewModel.requestRSVP(meetup: meetup, userId: userStateManager.currentUser?.userId ?? "")
                                        withAnimation {
                                            isRSVPed = true
                                        }
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
                            do {
                                try await viewModel.bookmarkMeetup(userId: userStateManager.currentUser?.userId ?? "", meetupId: meetup.id)
                                withAnimation {
                                    isBookmarked = true
                                }
                            } catch {
                                isErrorAlertPresented = true
                            }
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .padding()
                            .animation(.easeInOut, value: isBookmarked) // Animation for bookmark
                    }
                })
                Spacer()
                .navigationTitle("Meetup Details")
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
            .padding(.horizontal, 50)
            .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                ChatView(conversationId: viewModel.conversationId ?? "")
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.getHost(userId: meetup.organizerId ?? "")
                        try await viewModel.loadImage(from: meetup.imageURL ?? "")
                        
                        // Set the RSVP and Bookmark state on appear
                        isRSVPed = userStateManager.currentUser?.rsvpMeetups?.contains(meetup.id) ?? false
                        isBookmarked = userStateManager.currentUser?.bookmarkedMeetups?.contains(meetup.id) ?? false
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
        }
    }
}
