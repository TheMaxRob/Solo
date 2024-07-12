//
//  SpainView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct SpainView: View {
    
    var start: Date
    var end: Date
    
    var body: some View {
        VStack {
            ZStack {
                Image("SpainMap")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                GeometryReader { geometry in
                    
                    // Madrid
                    NavigationLink {
                        MeetupsView(city: "Madrid", country: "Spain", start: start, end: end)
                    } label: {
                        CityView(cityName: "Madrid", country: "Spain", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4)
                    
                    // Barcelona
                    NavigationLink {
                        MeetupsView(city: "Barcelona", country: "Spain", start: start, end: end)
                    } label: {
                        CityView(cityName: "Barcelona", country: "Spain", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.3)
                    
                    // Sevilla
                    NavigationLink {
                        MeetupsView(city: "Sevilla", country: "Spain", start: start, end: end)
                    } label: {
                        CityView(cityName: "Sevilla", country: "Spain", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.35, y: geometry.size.height * 0.715)
                }
                .frame(width: 400, height: 400)
            }
            .frame(width: 400, height: 400)
        }
    }
}

#Preview {
    SpainView(start: Date(), end: Date())
}
