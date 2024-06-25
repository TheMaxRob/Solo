//
//  PublicProfileView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

@MainActor
final class PublicProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    @Published var profileUser: DBUser? = nil
    @Published var user: DBUser? = nil
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
    
    
    func getUser(userId: String) async throws {
        profileUser = try await UserManager.shared.getUser(userId: userId)
        print("profileUser: \(String(describing: profileUser))")
    }
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
}

struct PublicProfileView: View {
    
    @StateObject private var viewModel = PublicProfileViewModel()
    var userId: String
    
    var body: some View {
        NavigationStack {
            VStack {
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 85))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
                }
                
                Text("\(viewModel.profileUser?.firstName ?? "") \(viewModel.profileUser?.lastName ?? "")")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Home Country: \(viewModel.profileUser?.homeCountry ?? "Unknown")")
                    .padding(30)
                Text("\(viewModel.profileUser?.age ?? "Unknown Age") years old")
                    .padding(.bottom)
                
                Text("\(viewModel.profileUser?.bio ?? "This user has no biography.")")
                
                Spacer()
            }
            .frame(width: 400)
            .background(.yellow)
            .onAppear {
                Task {
                    try await viewModel.getUser(userId: userId)
                    try await viewModel.loadImage(from: viewModel.profileUser?.photoURL ?? "")
                }
            }
        }
        
        
    }
}

#Preview {
    PublicProfileView(userId: "")
}
