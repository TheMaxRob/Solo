//
//  MeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

@MainActor
final class MeetupsViewModel: ObservableObject {
    @Published var meetups: [Meetup] = []
    @Published var errorMessage: String? = nil
    
    func fetchMeetups(country: String, city: String, start: Date, end: Date) async throws {
        do {
            let unFilteredMeetups = try await MeetupManager.shared.fetchMeetups(country: country, city: city)
            meetups = MeetupManager.shared.filterMeetupsByTimeFrame(meetups: unFilteredMeetups, start: start, end: end)
        } catch {
            errorMessage = "Error fetching meetups."
        }
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
            ScrollView {
                LazyVStack {
                    Divider()
                    ForEach(viewModel.meetups) { meetup in
                        NavigationLink(destination: MeetupDetailsView(meetup: meetup)) {
                            VStack {
                                MeetupView(meetup: meetup)
                                    .id(meetup.id) // Add explicit ID
                                Divider()
                            }
                        }
                    }
                }
                Spacer()
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.errorMessage ?? "Something went wrong."),
                      dismissButton: .default(Text("OK")))
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
        .task {
            do {
                try await viewModel.fetchMeetups(country: country, city: city, start: start, end: end)
            } catch {
                isErrorAlertPresented = true
            }
        }
    }
}


#Preview {
    MeetupsView(city: "Barcelona", country: "Spain", start: Date(), end: Date())
}
