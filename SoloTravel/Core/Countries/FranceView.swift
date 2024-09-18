//
//  FranceView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct FranceView: View {
    
    var start: Date
    var end: Date
    
    var body: some View {
        VStack {
            ZStack {
                Image("FranceMap")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                GeometryReader { geometry in
                    
                    // Paris
                    NavigationLink {
                        MeetupsView(city: "Paris", country: "France", start: start, end: end)
                    } label: {
                        CityView(cityName: "Paris", country: "France", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.53, y: geometry.size.height * 0.535)
                    
                    // Nice
                    NavigationLink {
                        MeetupsView(city: "Nice", country: "France", start: start, end: end)
                    } label: {
                        CityView(cityName: "Nice", country: "Paris", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.65, y: geometry.size.height * 0.75)
                }
                .frame(width: 400, height: 400)
            }
            .frame(width: 400, height: 400)
        }
    }
}

#Preview {
    FranceView(start: Date(), end: Date())
}
