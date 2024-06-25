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
    
    
    func fetchMeetups(city: String) async throws {
        meetups = try await MeetupManager.shared.fetchMeetups(city: city)
    }
}


struct MeetupsView: View {
    
    @Binding var isShowingMeetups: Bool
    @StateObject private var viewModel = MeetupsViewModel()
    var city: String
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.meetups) { meetup in
                        NavigationLink(destination: MeetupDetailsView(meetup: meetup)) {
                            VStack {
                                MeetupView(meetup: meetup)
                            }
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
                try await viewModel.fetchMeetups(city: city)
            }
        }
    }
}

#Preview {
    MeetupsView(isShowingMeetups: .constant(true), city: "Sevilla")
}
