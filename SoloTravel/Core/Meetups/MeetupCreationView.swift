//
//  MeetupCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/4/24.
//

import SwiftUI

@MainActor
final class MeetupCreationViewModel: ObservableObject {
    var meetupTitle: String = ""
    var meetupDescription: String = ""
    var meetTime: Date = Date()
    var createdDate: Date = Date()
    var meetSpot: String = ""
    var city: String = ""
    var country: String = ""
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func createMeetup(userId: String, meetup: Meetup) async throws {
        do {
            try await UserManager.shared.createMeetup(userId: userId, meetup: meetup)
        } catch {
            print("Error creating meetup: \(error)")
        }
    }

}

struct MeetupCreationView: View {
    
   @StateObject private var viewModel = MeetupCreationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height: 75)
                
                BottomLineTextField(placeholder: "Meetup Title", text: $viewModel.meetupTitle)
                                    
                
                HStack {
                    BottomLineTextField(placeholder: "City", text: $viewModel.city)
                    BottomLineTextField(placeholder: "Meeting Spot", text: $viewModel.meetSpot)
                    BottomLineTextField(placeholder: "Country", text: $viewModel.country)
                }
                DatePicker("Meet Time:", selection: $viewModel.meetTime, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                    .foregroundStyle(.gray.opacity(0.8))
                
                
                                
                
                TextField("Description", text: $viewModel.meetupDescription, axis: .vertical)
                    .lineLimit(5)
                    .padding(5)
                    .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.963))
                    .padding()
                
                Button {
                    Task {
                        do {
                            try await viewModel.loadCurrentUser()
                            
                            let newMeetup = Meetup(title: viewModel.meetupTitle, description: viewModel.meetupDescription, meetTime: viewModel.meetTime, city: viewModel.city, country: viewModel.country, createdDate: Date(), organizerId: viewModel.user?.userId ?? "", meetSpot: viewModel.meetSpot, attendees: [], pendingUsers: [])
                            
                            try await viewModel.createMeetup(userId: viewModel.user?.userId ?? "", meetup: newMeetup)
                            dismiss()
                        } catch {
                            print("Error ocurred: \(error)")
                        }
                    }
                   
                } label: {
                    Text("Post Meetup")
                        .padding()
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 50)
                        .background(RoundedRectangle(cornerRadius: 20))
                }
                
                Spacer()
            }
            .background(.yellow)
            .navigationTitle("Create a Meetup")
        }
            
    }
}

#Preview {
    MeetupCreationView()
}
