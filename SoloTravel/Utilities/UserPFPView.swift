//
//  UserPFPView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/9/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
final class UserPFPViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    @Published var isShowingWelcomeView: Bool = false
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
}

struct UserPFPView: View {
    
    @StateObject private var viewModel = UserPFPViewModel()
    var user: DBUser
    
    var body: some View {
        NavigationStack {
            if let selectedImage = viewModel.profileImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 5)
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 85))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            
        }
        .onAppear {
            Task { try await viewModel.loadImage(from: user.photoURL ?? "") }
        }
    }
}

#Preview {
    UserPFPView(user: DBUser(userId: "12345", firstName: "Max", lastName: "Roberts"))
}
