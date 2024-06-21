//
//  MessageBubbleView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/25/24.
//

import SwiftUI

struct MessageBubbleView: View {
    
    var text: String
    var isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            Text(text)
                .padding(10)
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(15)
                .frame(maxWidth: 150, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(isCurrentUser ? .trailing : .leading, 16)
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        MessageBubbleView(text: "This is a sent message", isCurrentUser: true)
        MessageBubbleView(text: "This is a received message", isCurrentUser: false)
    }
    .padding()
}
