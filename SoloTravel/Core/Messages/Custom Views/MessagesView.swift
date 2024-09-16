//
//  MessagesView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct MessagesView: View {
    @StateObject var viewModel = MessagesViewModel()
    @State private var isErrorAlertPresented = false
    
    var body: some View {
        NavigationStack {
            List(viewModel.conversations) { conversation in
                NavigationLink {
                    ChatView(conversationId: conversation.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            
                            Text(viewModel.userNames.joined(separator: ", "))
                                .bold()
                                .font(.title3)
                                .onAppear {
                                    Task {
                                        try await viewModel.fetchUserNames(userIds: conversation.users)
                                    }
                                }
                                .padding(.bottom, 6)
                            
                            Text("\(conversation.lastMessage ?? "")")
                                .font(.subheadline)
                                .fontWeight(conversation.hasUnreadMessages && viewModel.user?.userId != conversation.mostRecentSenderId ? .bold : .regular)
                        }
                       
                        Spacer()
                        if conversation.hasUnreadMessages && viewModel.user?.userId != conversation.mostRecentSenderId {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 10, height: 10)
                        }
                    }
                    .onTapGesture {
                        print("onTapGesture")
                        Task {
                            do {
                                viewModel.selectedConversationId = conversation.id
                                print("conversationId: ", conversation.id)
                                try await viewModel.fetchMessages(conversationId: viewModel.selectedConversationId)
                                print("fetchMessages executed")
                            } catch {
                                isErrorAlertPresented = true
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        if let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid {
                            try await viewModel.loadCurrentUser()
                            try await viewModel.fetchConversations(for: userId)
                            try await viewModel.setUserMessagesRead(userId: userId)
                        }
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Messages")
                        .font(.headline)
                }
            }
            
            // No idea why this doesn't work
            .navigationTitle("Messages")
            
        }
    }
}

