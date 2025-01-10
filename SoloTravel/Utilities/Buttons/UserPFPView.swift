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
    private var currentLoadingTask: Task<Void, Error>?
    
    func loadImage(from url: String) async throws {
        // Cancel any existing loading task
        currentLoadingTask?.cancel()
        
        currentLoadingTask = Task {
            do {
                profileImage = try await UserManager.shared.loadImage(from: url)
            } catch {
                if !Task.isCancelled {
                    throw error
                }
            }
        }
        
        try await currentLoadingTask?.value
    }
    
    deinit {
        currentLoadingTask?.cancel()
    }
}

struct UserPFPView: View {
    @StateObject private var viewModel = UserPFPViewModel()
    var photoURL: String

    var body: some View {
        Group {
            if let selectedImage = viewModel.profileImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 30))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
        .task(id: photoURL) { 
            if !photoURL.isEmpty {
                try? await viewModel.loadImage(from: photoURL)
            }
        }
    }
}


#Preview {
    UserPFPView(photoURL: "")
}
#Preview {
    UserPFPView(photoURL: "")
}
