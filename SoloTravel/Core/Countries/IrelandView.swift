//
//  IrelandView.swift
//  SoloTravel
//
//  Created by Max Roberts on 9/16/24.
//

import SwiftUI

struct IrelandView: View {
    var start: Date
    var end: Date
    
    var body: some View {
        VStack {
            ZStack {
                Image("IrelandMap")
                    .resizable()
                    .frame(width: 400, height: 400)
                
                GeometryReader { geometry in
                    
                    // Madrid
                    NavigationLink {
                        MeetupsView(city: "Dublin", country: "Ireland", start: start, end: end)
                    } label: {
                        CityView(cityName: "Dublin", country: "Ireland", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.61, y: geometry.size.height * 0.6)
                    
                    // Dublin
                    NavigationLink {
                        MeetupsView(city: "Galway", country: "Ireland", start: start, end: end)
                    } label: {
                        CityView(cityName: "Galway", country: "Ireland", start: start, end: end)
                    }
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.35, y: geometry.size.height * 0.65)
                }
                .frame(width: 400, height: 400)
            }
            .frame(width: 400, height: 400)
        }
    }
}

#Preview {
    IrelandView(start: Date(), end: Date())
}
