//
//  CityView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

@MainActor
final class CityViewModel: ObservableObject {
    var meetupCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var isShowingMeetups: Bool = false
    
    func loadCityMeetupsCount(country: String, city: String, start: Date, end: Date) async {
        isLoading = true
        do {
            let meetups = try await MeetupManager.shared.fetchMeetups(country: country, city: city)
            meetupCount = MeetupManager.shared.filterMeetupsByTimeFrame(meetups: meetups, start: start, end: end).count
            
        } catch {
            print("Failed to fetch meetups: \(error)")
            meetupCount = 0
        }
        isLoading = false
    }
}

struct CityView: View {
    @StateObject var viewModel = CityViewModel()
    var cityName: String
    var country: String
    var start: Date
    var end: Date
    
    var body: some View {
        VStack {
            NavigationLink {
                MeetupsView(city: cityName, country: country, start: start, end: end)
            } label: {
                VStack(spacing: 2){
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.9))
                            .frame(width: 30, height: 30)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .foregroundColor(.white)
                        } else {
                            Text("\(viewModel.meetupCount)")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.loadCityMeetupsCount(country: country, city: cityName, start: start, end: end) }
        }
    }
    
    
}

#Preview {
    CityView(cityName: "Sevilla", country: "Spain", start: Date(), end: Date())
}


