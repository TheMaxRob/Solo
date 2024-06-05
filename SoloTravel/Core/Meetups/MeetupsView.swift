//
//  MeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

@MainActor
final class MeetupsViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @State var meetups: [Meetup] = []
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func fetchMeetups(city: String) async throws {
        try await MeetupManager.shared.fetchMeetups(city: city) { meetup in
            self.meetups.append(contentsOf: meetup)
        }
    }

    
    
    
//    func RSVPMeetup() {
//        guard let user else { return }
//        
//        Task {
//            do {
//                try await UserManager.shared.RSVPMeetup(meetup: meetup, userId: user.userId)
//                self.user = try await UserManager.shared.getUser(userId: user.userId)
//            } catch {
//                print("Error RSVPing to Meetup!")
//            }
//        }
//    }
}


struct MeetupsView: View {
    
    @Binding var isShowingMeetups: Bool
    @StateObject private var viewModel = MeetupsViewModel()
    var city: String
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        isShowingMeetups = false
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 55)
                    
                    Spacer()
                }
                
                Text("\(city) Meetups")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 16)
                
                List {
                    ForEach(viewModel.meetups) { meetup in
                        NavigationLink(destination: MeetupDetailsView(meetup: meetup)) {
                            VStack {
                                MeetupView(meetup: meetup)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Meetups")
                
                
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all) 
            .overlay(alignment: .topTrailing) {
                
            NavigationLink {
                MeetupCreationView()
            } label: {
                Image(systemName: "plus")
                    .tint(.blue)
            }
            }
        }
        .onAppear {
            Task {
                try await viewModel.fetchMeetups(city: city)
            }
        }
    }
}

#Preview {
    MeetupsView(isShowingMeetups: .constant(true), city: "Sevilla")
}
