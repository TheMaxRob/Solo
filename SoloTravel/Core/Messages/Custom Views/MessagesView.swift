//
//  MessagesView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct MessagesView: View {
    @StateObject var viewModel = MessagesViewModel()
    @State private var isShowingChat = false
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
                HStack {
                    VStack(alignment: .leading) {
                        Text(conversation.users.joined(separator: ", "))
                            .font(.headline)
                        Text(conversation.lastMessage ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .onTapGesture {
                    selectedConversation = conversation
                    viewModel.fetchMessages(for: conversation.id!)
                    isShowingChat = true
                }
            }
            .onAppear {
                // Fetch conversations for the current user
                if let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid {
                    viewModel.fetchConversations(for: userId)
                }
            }
            .navigationTitle("Messages")
            .background(
                NavigationLink(destination: ChatView(viewModel: viewModel, conversation: selectedConversation), isActive: $isShowingChat) {
                    EmptyView()
                }
                
            )
        }
    }
}

struct ChatView: View {
    @ObservedObject var viewModel: MessagesViewModel
    @State private var messageText: String = ""
    var conversation: Conversation?
    
    var body: some View {
        VStack {
            List(viewModel.messages) { message in
                Text(message.content)
            }
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    if let conversationId = conversation?.id, let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid {
                        Task {
                            await viewModel.sendMessage(to: conversationId, content: messageText, senderId: userId, recipientId: conversation!.users.filter { $0 != userId }.first!)
                            messageText = ""
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
    }
}
