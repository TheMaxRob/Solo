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
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height: 75)
                
                TextField("Meetup Title", text: $viewModel.meetupTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                
                TextField("City", text: $viewModel.city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Meeting Spot", text: $viewModel.meetSpot)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                DatePicker("Meet Time:", selection: $viewModel.meetTime, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                
                
                                
                
                TextField("Description", text: $viewModel.meetupDescription, axis: .vertical)
                    .lineLimit(5)
                    .padding(5)
                    .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.963))
                    .padding()
                
                Button {
                    Task {
                        do {
                            try await viewModel.loadCurrentUser()
                            
                            let newMeetup = Meetup(id: UUID().uuidString, title: viewModel.meetupTitle, description: viewModel.meetupDescription, meetTime: viewModel.meetTime, city: viewModel.city, createdDate: Date(), organizerId: viewModel.user?.userId ?? "", meetSpot: viewModel.meetSpot)
                            
                            try await viewModel.createMeetup(userId: viewModel.user?.userId ?? "", meetup: newMeetup)
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
            .navigationTitle("Create a Meetup")
        }
            
    }
}

#Preview {
    MeetupCreationView()
}
