//
//  MessagesViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

final class MessagesViewModel: ObservableObject {
    @Published var isShowingPersonalMessageView: Bool = false
    @Published var selectedUser: User = User()
}
