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
    @Published var image: UIImage? = nil
    @Published var errorMessage: String? = nil
    
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error fetching your user profile."
        }
    }
    
    
    func fetchMeetups(country: String, city: String, start: Date, end: Date) async throws {
        do {
            let unFilteredMeetups = try await MeetupManager.shared.fetchMeetups(country: country, city: city)
            meetups = MeetupManager.shared.filterMeetupsByTimeFrame(meetups: unFilteredMeetups, start: start, end: end)
        } catch {
            errorMessage = "Error fetching meetups."
        }
    }
    
    
    func loadImage(from url: String) async throws {
        image = try await UserManager.shared.loadImage(from: url)
    }

}


struct MeetupsView: View {
    @StateObject private var viewModel = MeetupsViewModel()
    @State private var isErrorAlertPresented = false
    var city: String
    var country: String
    var start: Date
    var end: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                ForEach(viewModel.meetups) { meetup in
                    NavigationLink(destination: MeetupDetailsView(meetup: meetup)) {
                        VStack {
                            MeetupView(meetup: meetup)
                            Divider()
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("\(city) Meetups")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MeetupCreationView(city: city, country: country)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.fetchMeetups(country: country, city: city, start: start, end: end)
                } catch {
                    isErrorAlertPresented = true
                }
            }
        }
    }
}

#Preview {
    MeetupsView(city: "Barcelona", country: "Spain", start: Date(), end: Date())
}
