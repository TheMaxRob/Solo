//
//  MessageCellView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct MessageCellView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .font(.largeTitle)
                .padding(.horizontal)
            VStack(alignment: .leading) {
                Text("Max Roberts")
                    .bold()
                    .font(.title3)
                    .padding(.bottom, 2)
                Text("Sample latest message")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        
    }
}

#Preview {
    MessageCellView()
}
