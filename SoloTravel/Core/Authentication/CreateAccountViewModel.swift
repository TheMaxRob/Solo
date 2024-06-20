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
    
    func signUp() async throws {
        print("signUp vm called")
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.") 
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        print("Authdataresult – createUser successful")
        // try await UserManager.shared.createNewUser(auth: authDataResult)
        let user =  DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        print("signUp successful")
    }
}
