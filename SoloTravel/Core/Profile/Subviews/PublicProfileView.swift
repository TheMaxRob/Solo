//
//  PublicProfileView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct PublicProfileView: View {
    
    @StateObject private var viewModel = PublicProfileViewModel()
    //var userId: String
    var profileUser: DBUser?
    var profileUserId: String?
    var profileImage: UIImage?
    @State private var showMessageAlert = false
    @State private var alertMessage = ""
    @State private var didBlockUser = false
    @State private var showBlockAlert = false
    @State private var isErrorAlertPresented = false
    @State private var showReportAlert = false
    @State private var showReportSheet = false
    @State private var reportReason = ""
    private var isBlocked: Bool {
        user.blockedUsers?.contains(viewModel.profileUser?.userId ?? "") == true ||
        user.blockedBy?.contains(viewModel.profileUser?.userId ?? "") == true
    }
    var user: DBUser

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Profile image and user details
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
                    
                    Text("\(profileUser?.firstName ?? viewModel.profileUser?.firstName ?? "") \(profileUser?.lastName ?? viewModel.profileUser?.lastName ?? ""), \(profileUser?.age ?? viewModel.profileUser?.age ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Message button
                    Button {
                        Task {
                            if (user.blockedUsers?.contains(where: { $0 == viewModel.profileUser?.userId ?? "" }) == true) {
                                alertMessage = "You have blocked this user."
                                showMessageAlert = true
                            } else if (user.blockedBy?.contains(where: { $0 == viewModel.profileUser?.userId ?? "" }) == true) {
                                alertMessage = "You have been blocked by this user."
                                showMessageAlert = true
                            } else {
                                do {
                                    viewModel.conversationId = try await viewModel.createConversation(with: viewModel.profileUser?.userId ?? "")
                                } catch {
                                    isErrorAlertPresented = true
                                }
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
                    
                    Text("🇺🇸 \(profileUser?.homeCountry ?? viewModel.profileUser?.homeCountry ?? "Unknown")")
                        .padding(30)
                    
                    Text("About me")
                        .bold()
                        .font(.headline)
                    
                    Text("\(profileUser?.bio ?? viewModel.profileUser?.bio ?? "")")
                        .padding()
                    
                    // Report User Button
                    if (profileUser?.userId ?? viewModel.profileUser?.userId ?? "" != user.userId) {
                        Button {
                            showReportSheet = true  // Show the report modal
                        } label: {
                            Text("Report User")
                                .frame(width: 150, height: 50)
                                .background(.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .foregroundStyle(.black)
                        }
                    }
                    
                    // Block & Unblock Button
                    if (profileUser?.userId ?? viewModel.profileUser?.userId ?? "" != user.userId) {
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
                                            do {
                                                try await viewModel.blockUser(userId: user.userId, blockedUser: viewModel.profileUser?.userId ?? "")
                                            } catch {
                                                isErrorAlertPresented = true
                                            }
                                        } else {
                                            do {
                                                try await viewModel.unblockUser(userId: user.userId, unblockedUser: viewModel.profileUser?.userId ?? "")
                                            } catch {
                                                isErrorAlertPresented = true
                                            }
                                        }
                                        do {
                                            try await viewModel.loadCurrentUser()
                                        } catch {
                                            isErrorAlertPresented = true
                                        }
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
                        do {
                            //try await viewModel.loadCurrentUser()
                            //print("user in PublicProfileView: \(user)")
                            //print("profileUser in PublicProfileView: \(profileUser)")
                            if (profileUser == nil) {
                                try await viewModel.getUser(userId: profileUserId ?? "")
                            }
                            try await viewModel.loadImage(from: viewModel.profileUser?.photoURL ?? "")
                        } catch {
                            isErrorAlertPresented = true
                        }
                    }
                }
                .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                    ChatView(conversationId: viewModel.conversationId ?? "")
                }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showReportSheet) {
                ReportUserSheet(userId: user.userId, reportedUserId: viewModel.profileUser?.userId ?? "", viewModel: viewModel, isPresentingSheet: $showReportSheet)
            }
        }
    }
}

#Preview {
    PublicProfileView(profileUser: DBUser(userId: ""), user: DBUser(userId: ""))
}


struct ReportUserSheet: View {
    var userId: String
    var reportedUserId: String
    var viewModel: PublicProfileViewModel
    @Binding var isPresentingSheet: Bool
    @State private var reportReason = ""
    @State private var isSubmitting = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Report User")
                    .font(.headline)
                    .padding()

                Text("Please provide a reason for reporting this user:")
                    .padding()

                TextEditor(text: $reportReason)
                    .frame(height: 150)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                
                Spacer()
                
                Button {
                    isSubmitting = true
                    Task {
                        do {
                            // Call the report user function here
                            try await viewModel.reportUser(userId: userId, reportedUserId: reportedUserId, content: reportReason)
                            
                            // Switch to the main thread to dismiss the sheet
                            DispatchQueue.main.async {
                                isSubmitting = false
                                isPresentingSheet = false
                            }
                        } catch {
                            // Handle error and ensure UI updates are on main thread
                            DispatchQueue.main.async {
                                isSubmitting = false
                                print("Error reporting user: \(error)")
                            }
                        }
                    }
                } label: {
                    Text("Submit Report")
                        .frame(width: 200, height: 50)
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .foregroundStyle(.white)
                }
                .disabled(reportReason.isEmpty || isSubmitting)
                .padding()
            }
            .padding()
        }
    }
}
