//
//  ForgotPasswordView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/12/24.
//

import SwiftUI

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    var email: String = ""
    @Published var alertItem: AlertItem?
    
    func sendResetPasswordEmail(email: String) {
        print("viewModel sendResetPasswordEmail triggered: \(email)")
        UserManager.shared.sendResetPasswordEmail(email: email)
    }
}

struct ForgotPasswordView: View {
    
    @StateObject private var viewModel = ForgotPasswordViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter your email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button {
                    if viewModel.email.isValidEmail {
                        viewModel.sendResetPasswordEmail(email: viewModel.email)
                    } else {
                        viewModel.alertItem = AlertContext.invalidForm
                    }
                } label: {
                    Text("Send Reset Password Email")
                }
                .navigationTitle("Reset Password")
                
                Spacer().frame(height: 150)
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
