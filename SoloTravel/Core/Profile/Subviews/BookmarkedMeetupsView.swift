//
//  BookmarkedMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

@MainActor
final class BookMarkedMeetupViewModel: ObservableObject {
    func getMeetup(meetupId: String) async throws -> Meetup? {
        return try await MeetupManager.shared.getMeetup(meetupId: meetupId)
    }
}

struct BookmarkedMeetupsView: View {
    @State private var meetups: [Meetup] = []
    @State private var isLoading = true
    @StateObject private var viewModel = BookMarkedMeetupViewModel()
    @EnvironmentObject private var userStateManager: UserStateManager

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading meetups...")
            } else if meetups.isEmpty {
                Text("No bookmarked meetups found.")
            } else {
                ForEach(meetups, id: \Meetup.id) { meetup in
                    MeetupView(meetup: meetup)
                }
            }
        }
        .navigationTitle("Saved Meetups")
        .padding(.top, 15)
        Spacer()
        .task {
            await loadMeetups()
        }
    }

    private func loadMeetups() async {
        guard let bookmarkedMeetupIds = userStateManager.currentUser?.bookmarkedMeetups else {
            isLoading = false
            return
        }

        do {
            let fetchedMeetups = try await withThrowingTaskGroup(of: Meetup?.self) { group in
                for meetupId in bookmarkedMeetupIds {
                    group.addTask {
                        return try await viewModel.getMeetup(meetupId: meetupId)
                    }
                }

                var results: [Meetup] = []
                for try await result in group {
                    if let meetup = result {
                        results.append(meetup)
                    }
                }
                return results
            }
            meetups = fetchedMeetups
        } catch {
            print("Failed to load meetups: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    BookmarkedMeetupsView()
}
