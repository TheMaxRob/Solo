//
//  AccountButton.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct AccountButton: View {
    
    var image: Image?
    
    var body: some View {
        ZStack {
            if (image != nil) {
                image!
                    .resizable()
                    .scaledToFit()
                    .frame(height:75)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
            else {
                Image(systemName: "person.crop.circle")
            }
        }
        .font(Font.system(size: 75))
    }
}

#Preview {
    AccountButton(image: Image("ProfilePic"))
}
