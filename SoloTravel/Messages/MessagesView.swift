//
//  MessagesView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

@MainActor
final class MessagesViewModel: ObservableObject {
    @Published var isShowingPersonalMessageView: Bool = false
    //@Published var selectedUser: User = User()
}

struct MessagesView: View {
    
    @StateObject var viewModel = MessagesViewModel()
    @State private var isNavigating = false
    
    var body: some View {
        NavigationView {
            
            // Need to get users here from firebase. Each user has an item that is an array of all the people they are messaging?
//            List(MockUsers.mockUsers ) { user in //currentUser.message_threads
//                MessageCellView(user: user)
//                    .onTapGesture {
//                        viewModel.selectedUser = user
//                        isNavigating = true
//                        PersonalMessageView(selfUser: user, toUser: user)
//                    }
//                    .background(
//                        NavigationLink(destination: PersonalMessageView(selfUser: viewModel.selectedUser, toUser: viewModel.selectedUser, currentMessage: "Current Message"),
//                                       isActive: $isNavigating) {
//                            EmptyView()
//                        }
//                    )
//                
//                
//            }
            Text("Messages View")
            .navigationTitle("Messages")
        }
    }
}



#Preview {
    MessagesView()
}
