import SwiftUI

struct MeetupDetailsView: View {
    
    @StateObject private var viewModel = MeetupDetailsViewModel()
    @State private var isRSVPed = false
    var meetup: Meetup
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if let meetupImage = viewModel.image {
                    Image(uiImage: meetupImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: 400)
                }
                
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
                
                if viewModel.user?.userId != meetup.organizerId {
                    HStack {
                        Button {
                            Task {
                                if (viewModel.user?.blockedUsers?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                    alertMessage = "You have blocked this user."
                                    showAlert = true
                                } else if (viewModel.user?.blockedBy?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                    alertMessage = "You have been blocked by this user."
                                    showAlert = true
                                } else {
                                    viewModel.requestRSVP(meetup: meetup)
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
                            } else if viewModel.user?.rsvpMeetups?.contains(where: { $0 == meetup.id }) == true || ((viewModel.user?.rsvpRequests?.contains(where: { $0 == meetup.id }) == true)) {
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
                                try await viewModel.loadCurrentUser()
                                if (viewModel.user?.blockedUsers?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                    alertMessage = "You have blocked this user."
                                    showAlert = true
                                } else if (viewModel.user?.blockedBy?.contains(where: { $0 == viewModel.host?.userId ?? "" }) == true) {
                                    alertMessage = "You have been blocked by this user."
                                    showAlert = true
                                } else {
                                    viewModel.conversationId = try await viewModel.createConversation(with: meetup.organizerId ?? "")
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
                    .alert(isPresented: $showAlert, content: {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    })
                    .padding(.horizontal, 50)
                    .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                        ChatView(conversationId: viewModel.conversationId ?? "")
                    }

                }
                Spacer()
                    .navigationTitle("Meetup Details")
            }
            .onAppear {
                Task {
                    try await viewModel.loadCurrentUser()
                    print(viewModel.user?.rsvpMeetups ?? [])
                    print(viewModel.user?.rsvpRequests ?? [])
                    print(viewModel.user?.rsvpMeetups?.contains(where: { $0 == meetup.id }) == true || ((viewModel.user?.rsvpRequests?.contains(where: { $0 == meetup.id }) == true)))
                    try await viewModel.getHost(userId: meetup.organizerId ?? "")
                    try await viewModel.loadImage(from: meetup.imageURL ?? "")
                }
            }
        }
    }
}
