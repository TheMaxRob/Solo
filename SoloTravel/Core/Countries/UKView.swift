//
//  UKView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct UKView: View {
    
    var start: Date
    var end: Date
    
    var body: some View {
        Image("UKMap")
            .resizable()
            .frame(width: 300, height: 400)
    }
}

#Preview {
    UKView(start: Date(), end: Date())
}
