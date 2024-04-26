//
//  MessageBubbleView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct MessageBubbleView: View {
    
    var text: String
    
    var body: some View {
        ZStack {
            Text("\(text)")
            // MARK: Figure out how to make the bubble size with the text
        }
    }
}

#Preview {
    MessageBubbleView(text: "Sample Text")
}
