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
            List(viewModel.messages) { message in
                MessageBubbleView(text: message.content)
            }
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    Task {
                        print("Task Entered")
                        if viewModel.user == nil {
                            print("User == nil")
                            try await viewModel.loadCurrentUser()
                        }
                        
                        print("User Successfully Loaded")
                        if let conversation = try? await viewModel.fetchConversation(conversationId: conversationId) {
                            print("Conversation successfuly created")
                            try await viewModel.sendMessage(to: conversationId, content: messageText, senderId: viewModel.user?.userId ?? "", recipientId: conversation.users.filter { $0 != viewModel.user?.userId }.first!)
                            print("Message Sent - resetting messageText")
                            messageText = ""
                            try await viewModel.fetchMessages(conversationId: conversationId)
                        } else {
                            print("Error sending message.")
                        }
                        
                    }
                }
            }
            .padding()
        .navigationTitle("Chat")
        
        }
        .onAppear {
            Task {
                try await viewModel.fetchMessages(conversationId: conversationId)
            }
        }
    }
}
