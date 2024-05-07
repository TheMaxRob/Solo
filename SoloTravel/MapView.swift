//
//  MapView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/1/24.
//

import SwiftUI

struct MapView: View {
    
    var city: String
    
    var body: some View {
        
        NavigationStack {
            Text("Map View!")
            .navigationTitle("\(city)")
        }
        
        // MARK: Figure out how to make this map exist.
        
        // Map of selected city
    }
}

#Preview {
    MapView(city: "Sevilla")
}
