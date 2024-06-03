//
//  PersonalMessageView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

@MainActor

final class PersonalMessageViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    var conversationId: String?
    @Published var messages: [Message] = []
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func fetchMessages() {
        guard let conversationId = conversationId else { return }
            MessageManager.shared.fetchMessages(conversationId: conversationId) { [weak self] messages in
                DispatchQueue.main.async {
                    self?.messages = messages
                }
            }
        }
}


struct PersonalMessageView: View {
    
    @StateObject var viewModel = PersonalMessageViewModel()
    var conversationId: String
    
    
    var body: some View {
        Text("Message View")
        Text("Conversation Id: \(conversationId)")
            .navigationTitle("\(viewModel.user?.firstName ?? "Unknown" + (viewModel.user?.lastName ?? ""))")
            .onAppear {
                viewModel.fetchMessages()
            }
    }
        
}

#Preview {
    PersonalMessageView(conversationId: "12345")
}
