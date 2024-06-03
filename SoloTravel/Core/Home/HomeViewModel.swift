//
//  HomeViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI
import Firebase

final class HomeViewModel: ObservableObject {
    //@Published var emptyClass: Class = Class(name: "", professor: "", location: "", color: CodableColor(Color(.systemBackground)))
    @Published var selectedCity: String = ""
    @Published var selectedStay: String = ""
    
    
    func updateUserCity(city: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        // MARK: This needs logic to update a specific field in the user's file
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
}
