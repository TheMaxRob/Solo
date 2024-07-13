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
    var user: DBUser
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .topLeading) {
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
                    }
                }
                
            }
            .padding()
            .frame(width: 345, height: 130)
            .background(.yellow)
            .shadow(radius: 5, x: 3, y: 3)
            .onAppear {
                print("Other User Cell View Appeared!")
                Task { try await viewModel.loadImage(from: user.photoURL ?? "") }
            }
        }
    }
}

#Preview {
    OtherUserCellView(user: DBUser(userId: "12345", firstName: "Max", lastName: "Roberts"))
}
