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
        VStack {
            VStack(alignment: .center) {
                NavigationLink {
                    PublicProfileView(userId: "")
                } label: {
                    UserPFPView(user: DBUser(userId: ""))
                }
                Text("Max Roberts")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.black)
            }
        }
        .padding()
        .frame(width: 345, height: 130)
        .shadow(radius: 5, x: 3, y: 3)
    }
}

#Preview {
    TestView()
}
