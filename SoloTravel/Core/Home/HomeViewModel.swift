//
//  HomeViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI
import Firebase

final class HomeViewModel: ObservableObject {
    //@Published var emptyClass: Class = Class(name: "", professor: "", location: "", color: CodableColor(Color(.systemBackground)))
    @Published var selectedCity: String = ""
    @Published var selectedStay: String = ""
}
