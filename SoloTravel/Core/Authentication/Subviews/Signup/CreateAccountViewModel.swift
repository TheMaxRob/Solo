//
//  CreateAccountViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/19/24.
//

import Foundation

@MainActor
final class CreateAccountViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isShowingProfileCreationView: Bool = false
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.") 
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        // try await UserManager.shared.createNewUser(auth: authDataResult)
        let user =  DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}
