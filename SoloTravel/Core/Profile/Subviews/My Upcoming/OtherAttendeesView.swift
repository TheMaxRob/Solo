//
//  OtherAttendeesView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/12/24.
//

import SwiftUI

@MainActor
final class OtherAttendeesViewModel: ObservableObject {
    
    @Published var attendees: [DBUser] = []
    func getOtherAttendees(userIds: [String]) async throws {
        print("UserIds: \(userIds)")
        for userId in userIds {
            attendees.append(try await UserManager.shared.getUser(userId: userId))
            print("Appended \(attendees.last)")
        }
    }
}

struct OtherAttendeesView: View {
    
    @StateObject private var viewModel = OtherAttendeesViewModel()
    var meetup: Meetup
    
    var body: some View {
        VStack {
            ForEach(viewModel.attendees) { attendee in
                OtherUserCellView(user: attendee)
            }
        }
        .onAppear {
            Task { try await viewModel.getOtherAttendees(userIds: meetup.attendees ?? []) }
        }
    }
}
