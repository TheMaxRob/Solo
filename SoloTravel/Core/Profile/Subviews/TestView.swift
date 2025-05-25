//
//  TestView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/15/24.
//

import SwiftUI

final class TestViewModel: ObservableObject {
    var text: String = ""
}

struct TestView: View {
    
    @StateObject private var viewModel = TestViewModel()
    
    var body: some View {
        Text("Hello")
    }
    
}

#Preview {
    TestView()
}
