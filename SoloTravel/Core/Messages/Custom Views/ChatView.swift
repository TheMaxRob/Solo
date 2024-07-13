//
//  ChatView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/12/24.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText: String = ""
    var conversationId: String
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider().frame(height: 3)

                    ScrollView {
                        VStack {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(
                                    text: message.content,
                                    isCurrentUser: message.senderId == viewModel.user?.userId
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        TextField("Message", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send") {
                            Task {
                                print("Task Entered")
                                if viewModel.user == nil {
                                    print("User == nil")
                                }
                                
                                print("User Successfully Loaded")
                                print("conversationId: \(conversationId)")
                                if let conversation = try? await viewModel.fetchConversation(conversationId: conversationId) {
                                    print("Conversation successfully created")
                                    try await viewModel.sendMessage(
                                        to: conversationId,
                                        content: messageText,
                                        senderId: viewModel.user?.userId ?? "",
                                        recipientId: conversation.users.filter { $0 != viewModel.user?.userId }.first!
                                    )
                                    messageText = ""
                                    try await viewModel.fetchMessages(conversationId: conversationId)
                                } else {
                                    print("Error sending message.")
                                }
                            }
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
            .padding(.top, 45)
            }
            .onAppear {
                Task {
                    try await viewModel.loadUsers(conversationId: conversationId)
                    try await viewModel.fetchMessages(conversationId: conversationId)
                }
            }
            .onDisappear {
                if (viewModel.messages.isEmpty) {
                    Task { try await viewModel.deleteConversation(conversationId: conversationId) }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .principal) {
                    if viewModel.isLoadingUsers {
                        ProgressView("Loading...")
                    } else {
                        VStack(alignment: .center) {
                            if let otherUser = viewModel.other {
                                UserPFPView(user: otherUser)
                                Text("\(otherUser.firstName ?? "") \(otherUser.lastName ?? "")")
                            }
                        }
                        .padding(.top, 40)
                }
            }
        }
    }
}

#Preview {
    ChatView(conversationId: "")
}

