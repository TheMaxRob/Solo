//
//  PendingUserCellView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/8/24.
//

import SwiftUI

@MainActor
final class PendingUserCellViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func acceptRSVP(meetupId: String, userId: String) async throws {
        print("acceptRSVP")
        try await MeetupManager.shared.acceptUserToMeetup(meetupId: meetupId, userId: userId)
    }
    
    
    func declineRSVP(meetupId: String, userId: String) async throws {
        print("declineRSVP")
        try await MeetupManager.shared.declineUserToMeetup(meetupId: meetupId, userId: userId)
    }
}

struct PendingUserCellView: View {
    
    @StateObject var viewModel = PendingUserCellViewModel()
    var user: DBUser
    var meetupId: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                NavigationLink {
                    PublicProfileView(userId: user.userId)
                } label: {
                    UserPFPView(user: user)
                }
                Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.black)
                HStack {
                    Button(action: {
                        Task {
                            print("Accept Button Pressed")
                            try await viewModel.acceptRSVP(meetupId: meetupId, userId: user.userId)
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.green.opacity(0.5))
                                .frame(width: 110, height: 30)
                            Text("Accept")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: {
                        Task {
                            print("Decline Button Pressed")
                            try await viewModel.declineRSVP(meetupId: meetupId, userId: user.userId)
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.red.opacity(0.5))
                                .frame(width: 110, height: 30)
                            Text("Reject")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding()
        .frame(width: 345, height: 180)
        .background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10, x: 3, y: 5)
        .onAppear {
            Task {
                try await viewModel.loadImage(from: user.photoURL ?? "")
            }
        }
    }
}


    


#Preview {
    PendingUserCellView(user: DBUser(userId: "12345", firstName: "Max", lastName: "Roberts"), meetupId: "12345")
}
