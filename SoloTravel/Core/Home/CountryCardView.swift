//
//  CountryCardView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/10/24.
//

import SwiftUI

struct CountryCardView: View {
    
    var country: String
    
    var body: some View {
        switch country {
        case "Spain":
            SpainCardView()
        case "France":
            FranceCardView()
        case "United Kingdom":
            UKCardView()
        case "Ireland":
            IrelandCardView()
        case "Italy":
            ItalyCardView()
        case "Germany":
            GermanyCardView()
        default:
            Text("Oops, something went wrong.")
        }
    }
}

#Preview {
    CountryCardView(country: "Italy")
}
