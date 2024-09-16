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
    @State private var isErrorAlertPresented = false
    var conversationId: String
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom top bar
                VStack {
                    Spacer().frame(height: 55)
                    if let otherUser = viewModel.other {
                        UserPFPView(user: otherUser)
                        Text("\(otherUser.firstName ?? "") \(otherUser.lastName ?? "")")
                            .font(.headline)
                    }
                }
                .frame(height: 150)
                .background(Color(.systemBackground))
                
                Divider()
                
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
                
                if viewModel.canSendMessage() {
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
                } else {
                    Text("You cannot send messages to this user.")
                        .font(.footnote)
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    try await viewModel.loadCurrentUser()
                    print("conversationId on load: \(conversationId)")
                    viewModel.conversation = try await viewModel.fetchConversation(conversationId: conversationId) ?? Conversation(userIds: [], lastMessage: "", createdDate: Date())
                    try await viewModel.fetchMessages(conversationId: conversationId)
                } catch {
                    isErrorAlertPresented = true
                }
            }
        }
        .onDisappear {
            if (viewModel.conversation.messages == nil) {
                Task { try await viewModel.deleteConversation(conversationId: conversationId) }
            }
            // Task { try await viewModel.setMessagesRead(conversationId: conversationId) }
        }
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ChatView(conversationId: "")
}
