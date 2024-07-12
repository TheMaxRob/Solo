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
    @Published var meetups: [Meetup] = []
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func fetchMeetups(country: String, city: String, start: Date, end: Date) async throws {
        print("fetching meetups")
        var unFilteredMeetups = try await MeetupManager.shared.fetchMeetups(country: country, city: city)
        meetups = MeetupManager.shared.filterMeetupsByTimeFrame(meetups: unFilteredMeetups, start: start, end: end)
        print("Meetups: \(meetups)")
    }
}


struct MeetupsView: View {
    @StateObject private var viewModel = MeetupsViewModel()
    var city: String
    var country: String
    var start: Date
    var end: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(viewModel.meetups) { meetup in
                    NavigationLink(destination: MeetupDetailsView(meetup: meetup)) {
                        VStack {
                            MeetupView(meetup: meetup)
                        }
                    }
                }
                
                .scrollContentBackground(.hidden)
                .background(.yellow)
                .listStyle(PlainListStyle())
            }
            .navigationTitle("\(city) Meetups")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MeetupCreationView()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
        }
        .onAppear {
            Task {
                try await viewModel.fetchMeetups(country: country, city: city, start: start, end: end)
            }
        }
    }
}

#Preview {
    MeetupsView(city: "Barcelona", country: "Spain", start: Date(), end: Date())
}
