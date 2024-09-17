//
//  IrelandCardView.swift
//  SoloTravel
//
//  Created by Max Roberts on 9/16/24.
//

import SwiftUI

struct IrelandCardView: View {
    var body: some View {
        ZStack {
            Image("IrelandMap")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 100, height: 130)
                
        }
        .foregroundStyle(.gray.opacity(0.6))
        .shadow(radius: 10)
    }
}

#Preview {
    IrelandCardView()
}
