//
//  ProfilePicturesCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/21/24.
//

import SwiftUI

struct ProfilePicturesCreationView: View {
    
    @Binding var isNotAuthenticated: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Profile Pictures Creation View")
                    .frame(maxWidth: .infinity)
                    .navigationTitle("Profile Pictures")
                
                NavigationLink {
                    WelcomeView(isNotAuthenticated: $isNotAuthenticated)
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
            .background(.yellow)
        }

    }
}

#Preview {
    ProfilePicturesCreationView(isNotAuthenticated: .constant(true))
}
