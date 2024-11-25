//
//  UserStateManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 11/21/24.
//

//
//  UserStateManager.swift
//  SoloTravel
//
//  Created by Max Roberts on 9/29/24.
//

import SwiftUI

@MainActor
final class UserStateManager: ObservableObject {
   @Published var currentUser: DBUser?
   
   func updateUser(_ user: DBUser) {
       self.currentUser = user
   }
   
   func loadUser() async throws {
       let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
       self.currentUser = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
   }
   
   func refreshUser() async throws {
       guard let userId = currentUser?.userId else { return }
       self.currentUser = try await UserManager.shared.fetchUser(userId: userId)
   }
}


