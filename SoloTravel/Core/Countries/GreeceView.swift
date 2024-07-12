//
//  GreeceView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct GreeceView: View {
    
    var start: Date
    var end: Date
    
    var body: some View {
        Image("GreeceMap")
            .resizable()
            .frame(width: 400, height: 500)
    }
}

#Preview {
    GreeceView(start: Date(), end: Date())
}
