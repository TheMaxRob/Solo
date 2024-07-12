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
        Image("FranceMap")
            .resizable()
            .frame(width: 400, height: 400)
    }
}

#Preview {
    FranceView(start: Date(), end: Date())
}
