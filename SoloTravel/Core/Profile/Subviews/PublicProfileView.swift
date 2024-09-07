//
//  PublicProfileView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct PublicProfileView: View {
    
    @StateObject private var viewModel = PublicProfileViewModel()
    var userId: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let _ = viewModel.meetupImage {
                        Image("MaxPFP")
                            .resizable()
                            .scaledToFill()
                            .frame(minHeight: 450)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 85))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }
                    
                    Text("\(viewModel.profileUser?.firstName ?? "") \(viewModel.profileUser?.lastName ?? ""), \(viewModel.profileUser?.age ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button {
                        Task {
                            try await viewModel.loadCurrentUser()
                            viewModel.conversationId = try await viewModel.createConversation(with: viewModel.profileUser?.userId ?? "")
                        }
                    } label: {
                        Text("Message")
                            .frame(width: 125, height: 40)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .foregroundStyle(.white)
                    }
                    
                    Text("🇺🇸 \(viewModel.profileUser?.homeCountry ?? "Unknown")")
                        .padding(30)
                    
                    Text("About me")
                        .bold()
                        .font(.headline)
                    
                    Text("\(viewModel.profileUser?.bio ?? "This user has no biography.")")
                        .padding()
                    
                    Spacer()
                }
                .onAppear {
                    Task {
                        try await viewModel.getUser(userId: userId)
                        try await viewModel.loadImage(from: viewModel.profileUser?.photoURL ?? "")
                    }
                }
                .navigationDestination(isPresented: $viewModel.isShowingPersonalMessageView) {
                    ChatView(conversationId: viewModel.conversationId ?? "")
                }
            }
        }
        
        
    }
}

#Preview {
    PublicProfileView(userId: "")
}
