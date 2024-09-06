//
//  SpainCardView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/10/24.
//

import SwiftUI

struct SpainCardView: View {
    var body: some View {
        ZStack {
            Image("SpainMap")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 100, height: 130)
                
        }
        .foregroundStyle(.gray.opacity(0.6))
        .shadow(radius: 10)
    }
}

#Preview {
    SpainCardView()
}
