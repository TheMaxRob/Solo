//
//  GermanyView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct GermanyView: View {
    
    var start: Date
    var end: Date
    
    var body: some View {
        VStack {
            ZStack {
                Image("GermanyMap")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                GeometryReader { geometry in
                    
                    // Paris
                    NavigationLink {
                        MeetupsView(city: "Berlin", country: "Germany", start: start, end: end)
                    } label: {
                        CityView(cityName: "Berlin", country: "Germany", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.64, y: geometry.size.height * 0.5)
                    
                    // Nice
                    NavigationLink {
                        MeetupsView(city: "Munich", country: "Germany", start: start, end: end)
                    } label: {
                        CityView(cityName: "Munich", country: "Germany", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.47, y: geometry.size.height * 0.76)
                }
                .frame(width: 400, height: 400)
            }
            .frame(width: 400, height: 400)
        }
    }
}

#Preview {
    GermanyView(start: Date(), end: Date())
}
