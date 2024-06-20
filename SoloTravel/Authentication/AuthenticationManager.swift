//
//  AuthenticationManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init ()  { }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let result = AuthDataResultModel(user: authDataResult.user)
        return result
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    
    func signOut() throws  {
        try Auth.auth().signOut()
    }
    
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    func updatePassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: newPassword)
    }
    
    
    func updateEmail(newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: user.email ?? "")
    }
    
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
    }
}
