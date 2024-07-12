//
//  LoadingView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/12/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            ProgressView()
                .controlSize(.large)
                .tint(.green)
        }
        
    }
}

#Preview {
    LoadingView()
}
