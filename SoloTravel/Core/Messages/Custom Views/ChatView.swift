//
//  ChatView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/12/24.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel = ChatViewModel()
    @State private var messageText: String = ""
    var conversationId: String
    
    var body: some View {
        VStack {
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
        .navigationTitle("Chat")
        .onAppear {
            Task {
                try await viewModel.loadCurrentUser()
                try await viewModel.fetchMessages(conversationId: conversationId)
                print("UserId: \(String(describing: viewModel.user?.userId))")
            }
        }
    }
}
