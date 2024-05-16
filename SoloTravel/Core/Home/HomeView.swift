//
//  ContentView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 10) {
                    Text("S o l o")
                        .bold()
                        .font(Font.system(size: 60))
                    Text("Connect with other travelers")
                        .bold()
                    
                    Spacer()
                        .frame(height: 175)
                    
                    Text("Where are you staying?").bold()
                    HStack {
                        TextField("City", text:$viewModel.selectedCity)
                        TextField("Hotel/Hostel", text:$viewModel.selectedStay)
                    }
                    .padding(.bottom)
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 3)
                    
                    
                    NavigationLink {
                        MeetupsView(city: viewModel.selectedCity)
                    } label: {
                        Text("Connect")
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 125, height: 40)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
                    }
                    .onTapGesture {
                        Task {
                            try await viewModel.updateUserCity(city: viewModel.selectedCity)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HomeView()
}
