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
        Image("GermanyMap")
            .resizable()
            .frame(width: 500, height: 600)
    }
}

#Preview {
    GermanyView(start: Date(), end: Date())
}
