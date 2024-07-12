//
//  BookmarkedMeetupsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/24/24.
//

import SwiftUI

struct BookmarkedMeetupsView: View {
    var user: DBUser
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Bookmarked Meetups (not implemented)")
                    .frame(width: 400)
                    .background(.yellow)
                Spacer()
            }
            .background(.yellow)
            .navigationTitle("Saved Meetups")
        }
        
    }
}

#Preview {
    BookmarkedMeetupsView(user: DBUser(userId: "12345"))
}
