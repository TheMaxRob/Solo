//
//  MeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI
import MapboxMaps

@MainActor
final class MeetupViewModel: ObservableObject {
    @Published private(set) var host: DBUser = DBUser(userId: "")
    @Published var profileImage: UIImage? = nil
    @Published var errorMessage: String? = nil
    private var loadingTask: Task<Void, Error>?
    
    func getHost(userId: String) async throws {
        // Cancel any existing loading task
        loadingTask?.cancel()
        
        loadingTask = Task {
            do {
                host = try await UserManager.shared.fetchUser(userId: userId)
                if let photoURL = host.photoURL, !photoURL.isEmpty {
                    try await loadImage(from: photoURL)
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = "Error loading organizer's profile."
                    throw error
                }
            }
        }
        
        try await loadingTask?.value
    }
        
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    deinit {
        loadingTask?.cancel()
    }
}

struct MeetupView: View {
    @StateObject var viewModel = MeetupViewModel()
    @State private var isErrorAlertPresented = false
    var meetup: Meetup

    var body: some View {
        HStack {
            NavigationLink {
                PublicProfileView(profileUser: viewModel.host)
            } label: {
                UserPFPView(photoURL: viewModel.host.photoURL ?? "")
                    .id(meetup.organizerId) // Add explicit ID
            }

            Spacer()

            VStack {
                Text(meetup.title)
                    .font(.headline)
                Text(formatDayAndTime(date: meetup.meetTime ?? Date()))
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .frame(width: 350)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 10, x: 3, y: 5)
        .task(id: meetup.organizerId) { // Use task with ID instead of onAppear
            do {
                try await viewModel.getHost(userId: meetup.organizerId ?? "Unknown")
            } catch {
                isErrorAlertPresented = true
            }
        }
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Error"),
                  message: Text(viewModel.errorMessage ?? "Something went wrong."),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func formatDayAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    MeetupView(meetup: Meetup(title: "Title", description: "description", meetTime: Date(), city: "Paris", createdDate: Date(), organizerId: "organizerId", location: CLLocationCoordinate2D(), attendees: [], pendingUsers: [], imageURL: ""))
}
