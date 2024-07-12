//
//  CheckMarkButton.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/8/24.
//

import SwiftUI

struct CheckMarkButton: View {
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .opacity(0.7)
            .frame(width: 40, height: 40)
            .foregroundStyle(.green)
            .font(.system(size: 40))
            
    }
}

#Preview {
    CheckMarkButton()
}
