//
//  ProfilePicturesCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/21/24.
//

import SwiftUI

@MainActor
final class ProfilePicturesCreationViewModel: ObservableObject {
    @Published var isShowingWelcomeView: Bool = false
}

struct ProfilePicturesCreationView: View {
    
    @StateObject private var viewModel = ProfilePicturesCreationViewModel()
    @Binding var isNotAuthenticated: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Profile Pictures Creation View")
                    .frame(maxWidth: .infinity)
                    .navigationTitle("Profile Pictures")
                
                Button {
                    viewModel.isShowingWelcomeView = true
                                    } label: {
                    Text("Save and Finish Profile")
                        .padding()
                        .frame(width: 350)
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .navigationBarBackButtonHidden()
                Spacer()
            }
            // .background(.yellow)
            .fullScreenCover(isPresented: $viewModel.isShowingWelcomeView, content: {
                WelcomeView(isNotAuthenticated: $isNotAuthenticated, isShowingWelcomeView: $viewModel.isShowingWelcomeView)
            })
        }

    }
}

#Preview {
    ProfilePicturesCreationView(isNotAuthenticated: .constant(true))
}
