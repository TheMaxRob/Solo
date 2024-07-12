//
//  HomeViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI
import Firebase

final class HomeViewModel: ObservableObject {
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    let countries = ["France", "Germany", "Greece", "Italy", "Spain", "United Kingdom"]
    @Published var selectedCountry: String = ""
    @Published var selectedStay: Date = Date()
}
