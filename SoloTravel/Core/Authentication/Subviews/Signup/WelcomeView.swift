//
//  WelcomeView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/21/24.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isNotAuthenticated: Bool
    @Binding var isShowingWelcomeView: Bool
    let dismissAfter: TimeInterval = 2.0
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 275)
                
                Text("Welcome to Solo!")
                    .font(.title)
                    .bold()
                    .padding()
                    .frame(width: 400)
                
                Text("Have fun and stay safe!")
                    .font(.subheadline)
                
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
                    isShowingWelcomeView = false
                    isNotAuthenticated = false
                }
            }
        }
    }
}

#Preview {
    WelcomeView(isNotAuthenticated: .constant(true), isShowingWelcomeView: .constant(true))
}
