//
//  AcceptedUserCellView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/8/24.
//

import SwiftUI

@MainActor
final class AcceptedUserCellViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func removeUser(meetupId: String, userId: String) async throws {
        try await MeetupManager.shared.removeUserFromMeetup(meetupId: meetupId, userId: userId)
    }
}


struct AcceptedUserCellView: View {
    
    @StateObject var viewModel = AcceptedUserCellViewModel()
    var user: DBUser
    var meetupId: String
    
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
                Task { try await viewModel.loadImage(from: user.photoURL ?? "") }
            }
            .overlay(Button {
                Task {
                    print("userId being passed to removeUser() \(user.userId)")
                    try await viewModel.removeUser(meetupId: meetupId, userId: user.userId)
                }
            } label: {
                Image(systemName: "xmark")
            }.padding(5), alignment: .topTrailing)
        }
    }
}

#Preview {
    AcceptedUserCellView(user: DBUser(userId: "12345", firstName: "Max", lastName: "Roberts"), meetupId: "12345")
}
