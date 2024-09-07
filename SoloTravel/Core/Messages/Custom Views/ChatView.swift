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
                            ForEach(viewModel.conversation.messages ?? []) { message in
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
                                if viewModel.user == nil {
                                    print("User == nil")
                                    try await viewModel.loadCurrentUser()
                                    
                                }
                                try await viewModel.sendMessage(
                                    to: conversationId,
                                    content: messageText,
                                    senderId: viewModel.user?.userId ?? "",
                                    recipientId: viewModel.conversation.users.filter { $0 != viewModel.user?.userId }.first ?? ""
                                )
                                print("viewModel.sendMessage successful")
                                messageText = ""
                                try await viewModel.fetchMessages(conversationId: conversationId)
                            }
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    
                }
            .padding(.top, 45)
            }
            .onAppear {
                Task {
                    try await viewModel.loadCurrentUser()
                    print("conversationId on load: \(conversationId)")
                    viewModel.conversation = try await viewModel.fetchConversation(conversationId: conversationId) ?? Conversation(userIds: [], lastMessage: "", createdDate: Date())
                    try await viewModel.fetchMessages(conversationId: conversationId)
                }
            }
            .onDisappear {
                if (viewModel.conversation.messages == nil) {
                    Task { try await viewModel.deleteConversation(conversationId: conversationId) }
                }
                // Task { try await viewModel.setMessagesRead(conversationId: conversationId) }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .principal) {
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


#Preview {
    ChatView(conversationId: "")
}

