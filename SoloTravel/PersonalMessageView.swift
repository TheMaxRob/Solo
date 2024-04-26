//
//  PersonalMessageView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct PersonalMessageView: View {
    
    var user: User
    @StateObject var viewModel = PersonalMessageViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Personal Message View")
                TextField("Message", text: $viewModel.currentMessage)
                    .onSubmit {
                        viewModel.lastMessage = viewModel.currentMessage
                        viewModel.currentMessage = ""
                    }
                    .shadow(radius: 10)
                
            }
            .navigationTitle("\(user.firstName) \(user.lastName)")
        }
        

    }
}

#Preview {
    PersonalMessageView(user: MockUsers.mockUsers[0])
}
