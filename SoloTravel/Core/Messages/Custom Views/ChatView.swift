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
    @EnvironmentObject private var userStateManager: UserStateManager
    
    
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
                    .padding(.bottom)
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.conversation.messages ?? []) { message in
                            MessageBubbleView(
                                text: message.content,
                                isCurrentUser: message.senderId == userStateManager.currentUser?.userId ?? ""
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                if (viewModel.canSendMessage(user: userStateManager.currentUser ?? DBUser(userId: ""))) {
                    HStack {
                        TextField("Message", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send") {
                            Task {
                                try await viewModel.sendMessage(
                                    to: conversationId,
                                    content: messageText,
                                    senderId: userStateManager.currentUser?.userId ?? "",
                                    recipientId: viewModel.conversation.users.filter { $0 != userStateManager.currentUser?.userId }.first ?? ""
                                )
                                //print("viewModel.sendMessage successful")
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
        //.navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    print("conversationId on load: \(conversationId)")
                    viewModel.conversation = try await viewModel.fetchConversation(conversationId: conversationId, userId: userStateManager.currentUser?.userId ?? "") ?? Conversation(userIds: [], lastMessage: "", createdDate: Date())
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
