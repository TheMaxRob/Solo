//
//  MeetupView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

final class MeetupViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var host: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func getUser(userId: String) async throws {
        host = try await UserManager.shared.getUser(userId: userId)
    }
}

struct MeetupView: View {
    
    @StateObject var viewModel = MeetupViewModel()
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack {
                    Text("\(String(describing: meetup.title))")
                        .font(.headline)
                    Text("\(formatDayAndTime(date: meetup.meetTime))")
                    
                }
            }
           
        }
        
    }
    
    private func formatDayAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        return formatter.string(from: date)
    }
    
    
    
}

#Preview {
    MeetupView(meetup: Meetup(id: "id", title: "Title", description: "description", meetTime: Date(), city: "Paris", createdDate: Date(), organizerId: "organizerId", meetSpot: "Spot"))
}
