//
//  User.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct User: Codable, Identifiable {
    var firstName = ""
    var lastName = ""
    var email = ""
    var birthday = Date()
    var currentCity: String = ""
    var currentHostel: String = ""
    
    var id: String = ""
}

struct MockUsers {
    
    static let mockUsers = [
        User(firstName: "Max", lastName: "Roberts", email: "maxroberts2003@gmail.com", birthday: Date(), currentCity: "Sevilla", currentHostel: "Onefam Cathedral", id: "TheMaxRob"),
        
         User(firstName: "Charlie", lastName: "Ragona", email: "charlieragona2004@gmail.com", birthday: Date(), currentCity: "Sevilla", currentHostel: "Onefam Cathedral", id: "CharlieRagona")
    ]
}

