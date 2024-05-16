//
//  MeetupDetailsView.swift
//  SoloTravel
//
//  Created by Max Roberts on 5/16/24.
//

import SwiftUI

struct MeetupDetailsView: View {
    
    var meetup: Meetup
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(meetup.title)")
                    .font(.headline)
                    .padding(.bottom)
                
                Text("\(meetup.meetSpot)")
                    .font(.subheadline)
                
                Text("\(meetup.meetTime)")
                    .font(.subheadline)
                    .padding(.bottom)
                
                Text("\(meetup.description)")
                    .font(.caption)
            }
            .navigationTitle("Meetup Details")
            
        }
    }
}

#Preview {
    MeetupDetailsView()
}
