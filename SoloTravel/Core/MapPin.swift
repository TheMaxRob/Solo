//
//  MapAnnotationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 1/15/25.
//

import SwiftUI
import MapKit

struct MapPin: View {
    
    var proxy: MapProxy
    var coordinates: CLLocationCoordinate2D
    
    
    var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            Image(systemName: "location.circle.fill")
                .font(.largeTitle)
                .frame(width: frame.width, height: frame.height)
        }
    }
}


