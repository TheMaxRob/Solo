//
//  DeclineButton.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/8/24.
//

import SwiftUI

struct DeclineButton: View {
    var body: some View {
        Image(systemName: "x.circle.fill")
            .opacity(0.7)
            .frame(width: 40, height: 40)
            .foregroundStyle(.red)
            .font(.system(size: 40))
    }
}


#Preview {
    DeclineButton()
}
