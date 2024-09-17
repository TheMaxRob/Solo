//
//  CountryView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/7/24.
//

import SwiftUI

struct CountryView: View {
    
    var country: String
    var start: Date
    var end: Date
    
    var body: some View {
        switch country {
        case "Spain":
            SpainView(start: start, end: end)
        case "France":
            FranceView(start: start, end: end)
        case "United Kingdom":
            UKView(start: start, end: end)
        case "Ireland":
            IrelandView(start: start, end: end)
        case "Italy":
            ItalyView(start: start, end: end)
        case "Germany":
            GermanyView(start: start, end: end)
        default:
            Text("Oops, something went wrong.")
        }
    }
}

#Preview {
    CountryView(country: "Spain", start: Date(), end: Date())
}
