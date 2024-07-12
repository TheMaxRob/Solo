//
//  ForgotPasswordButton.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/12/24.
//

import SwiftUI

struct ForgotPasswordButton: View {
    
    @StateObject private var viewModel = ForgotPasswordViewModel()
    var body: some View {
        NavigationStack {
            NavigationLink {
                ForgotPasswordView()
            } label: {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    ForgotPasswordButton()
}
