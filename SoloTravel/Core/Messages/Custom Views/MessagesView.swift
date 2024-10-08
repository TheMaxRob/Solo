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
    
    
    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
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
                        Text("\(conversation.lastMessage ?? "")")
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        Task {
                            viewModel.selectedConversationId = conversation.id
                            try await viewModel.fetchMessages(conversationId: viewModel.selectedConversationId)
                            isShowingChat = true
                        }
                    }
                }
                
            }
            .onAppear {
                Task {
                    if let userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid {
                        try await viewModel.loadCurrentUser()
                        try await viewModel.fetchConversations(for: userId)
                    }
                
                }
            }
            .navigationTitle("Messages")
            .background(
                NavigationLink(destination: ChatView(conversationId: viewModel.selectedConversationId), isActive: $isShowingChat) {
                    EmptyView()
                }
                
            )
        }
    }
}

