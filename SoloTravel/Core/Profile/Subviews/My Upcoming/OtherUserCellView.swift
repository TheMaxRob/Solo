//
//  OtherUserCellView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/12/24.
//

import SwiftUI

@MainActor
final class OtherUserCellViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    
    func loadImage(from url: String) async throws {
        print("loadImage OtherUserCellViewModel")
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func removeUser(meetupId: String, userId: String) async throws {
        try await MeetupManager.shared.removeUserFromMeetup(meetupId: meetupId, userId: userId)
    }
}


struct OtherUserCellView: View {
    
    @StateObject var viewModel = OtherUserCellViewModel()
    var otherUser: DBUser
    @EnvironmentObject private var userStateManager: UserStateManager
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .center) {
                        NavigationLink {
                            PublicProfileView(profileUser: otherUser)
                        } label: {
                            UserPFPView(photoURL: userStateManager.currentUser?.photoURL ?? "")
                        }
                        Text("\(otherUser.firstName ?? "") \(otherUser.lastName ?? "")")
                            .bold()
                            .font(.title2)
                            .foregroundStyle(.black)
                    }
                }
                
            }
            .padding()
            .frame(width: 345, height: 130)
            //.background(.yellow)
            .shadow(radius: 5, x: 3, y: 3)
            .onAppear {
                Task { try await viewModel.loadImage(from: otherUser.photoURL ?? "") }
            }
        }
    }
}

#Preview {
    OtherUserCellView(otherUser: DBUser(userId: ""))
}
