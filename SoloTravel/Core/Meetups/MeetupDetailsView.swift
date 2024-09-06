//
//  MeetupDetailsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

struct MeetupDetailsView: View {
    
    @StateObject private var viewModel = MeetupDetailsViewModel()
    var meetup: Meetup
    
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
                
                HStack {
                    Button {
                        Task {
                            try await viewModel.loadCurrentUser()
                            viewModel.requestRSVP(meetup: meetup)
                        }
                    } label: {
                        Text("RSVP")
                            .frame(width: 90, height: 45)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 1)
                            )
                            .foregroundStyle(.green)
                        // Animate into checkmark, popup to show you requested RSVP
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            try await viewModel.loadCurrentUser()
                            viewModel.conversationId = try await viewModel.createConversation(with: meetup.organizerId ?? "")
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
                .padding(.horizontal, 50)
                .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                    ChatView(conversationId: viewModel.conversationId ?? "")
                }
                Spacer()
                    .navigationTitle("Meetup Details")
            }
            .onAppear {
                Task {
                    try await viewModel.getHost(userId: meetup.organizerId ?? "")
                    try await viewModel.loadImage(from: meetup.imageURL ?? "")
                }
            
            }
        }
    }
}
