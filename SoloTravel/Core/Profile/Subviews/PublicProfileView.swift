//
//  PublicProfileView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct PublicProfileView: View {
    
    @StateObject private var viewModel = PublicProfileViewModel()
    var userId: String
    var profileImage: UIImage?
    @State private var showMessageAlert = false
    @State private var alertMessage = ""
    @State private var didBlockUser = false
    @State private var showBlockAlert = false
    private var isBlocked: Bool {
        viewModel.user?.blockedUsers?.contains(viewModel.profileUser?.userId ?? "") == true ||
        viewModel.user?.blockedBy?.contains(viewModel.profileUser?.userId ?? "") == true
    }

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let _ = viewModel.meetupImage {
                        Image("MaxPFP")
                            .resizable()
                            .scaledToFill()
                            .frame(minHeight: 450)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 85))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }
                    
                    Text("\(viewModel.profileUser?.firstName ?? "") \(viewModel.profileUser?.lastName ?? ""), \(viewModel.profileUser?.age ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button {
                        Task {
                            if (viewModel.user?.blockedUsers?.contains(where: { $0 == viewModel.profileUser?.userId ?? "" }) == true) {
                                alertMessage = "You have blocked this user."
                                showMessageAlert = true
                            } else if (viewModel.user?.blockedBy?.contains(where: { $0 == viewModel.profileUser?.userId ?? "" }) == true) {
                                alertMessage = "You have been blocked by this user."
                                showMessageAlert = true
                            } else {
                                viewModel.conversationId = try await viewModel.createConversation(with: viewModel.profileUser?.userId ?? "")
                            }
                        }
                        
                    } label: {
                        Text("Message")
                            .frame(width: 125, height: 40)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .foregroundStyle(.white)
                    }
                    .alert(isPresented: $showMessageAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    Text("🇺🇸 \(viewModel.profileUser?.homeCountry ?? "Unknown")")
                        .padding(30)
                    
                    Text("About me")
                        .bold()
                        .font(.headline)
                    
                    Text("\(viewModel.profileUser?.bio ?? "")")
                        .padding()
                    
                    
                    // Block & Unblock Button
                    if (userId != viewModel.user?.userId) {
                        Button {
                            showBlockAlert = true
                        } label: {
                            Text(isBlocked ? "Unblock User" : "Block User")
                                .frame(width: 150, height: 50)
                                .background(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .foregroundStyle(.white)
                        }
                        .alert(isPresented: $showBlockAlert) {
                            return Alert(
                                        title: Text(isBlocked ? "Unblock" : "Block User"),
                                        message: Text(isBlocked ? "Are you sure you want to unblock this user? " : "Are you sure you want to block this user?"),
                                        primaryButton: .destructive(Text("Confirm")) {
                                            Task {
                                                if (!isBlocked) {
                                                    try await viewModel.blockUser(userId: viewModel.user?.userId ?? "", blockedUser: viewModel.profileUser?.userId ?? "")
                                                } else {
                                                    try await viewModel.unblockUser(userId: viewModel.user?.userId ?? "", unblockedUser: viewModel.profileUser?.userId ?? "")
                                                }
                                                try await viewModel.loadCurrentUser()
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                    }
                    
                    Spacer()
                }
                .onAppear {
                    Task {
                        try await viewModel.loadCurrentUser()
                        print("userId passed to file: \(userId)")
                        try await viewModel.getUser(userId: userId)
                        try await viewModel.loadImage(from: viewModel.profileUser?.photoURL ?? "")
                    }
                }
                .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                    ChatView(conversationId: viewModel.conversationId ?? "")
                }
            }
        }
        
        
    }
}

#Preview {
    PublicProfileView(userId: "")
}
