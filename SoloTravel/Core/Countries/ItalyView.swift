//
//  ItalyView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct ItalyView: View {
    
    var start: Date
    var end: Date
    
    var body: some View {
        VStack {
            Image("ItalyMap")
                .resizable()
                .frame(width: 425, height: 550)
            
            Spacer()
                .frame(height: 100)
        }
        
    }
}

#Preview {
    ItalyView(start: Date(), end: Date())
}
