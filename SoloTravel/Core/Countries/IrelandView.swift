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
        Image("IrelandMap")
            .resizable()
            .frame(width: 500, height: 600)
    }
}

#Preview {
    IrelandView(start: Date(), end: Date())
}
