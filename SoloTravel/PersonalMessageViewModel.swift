//
//  PersonalMessageViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

final class PersonalMessageViewModel: ObservableObject {
    
    @Published var currentMessage: String = ""
    @Published var didSendMessage: Bool = false
    @Published var lastMessage: String = ""
}
