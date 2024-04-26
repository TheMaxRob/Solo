//
//  MessagesView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct MessagesView: View {
    
    @StateObject var viewModel = MessagesViewModel()
    
    var body: some View {
        NavigationStack {
            List(MockUsers.mockUsers) { user in
                MessageCellView(user: user)
                    .onTapGesture {
                        viewModel.isShowingPersonalMessageView = true
                        viewModel.selectedUser = user
                    }
            }
            
            .navigationTitle("Messages")
        }
        
        if (viewModel.isShowingPersonalMessageView) {
            PersonalMessageView(user: viewModel.selectedUser)
        }
       
    }
}

#Preview {
    MessagesView()
}
