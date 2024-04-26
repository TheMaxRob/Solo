//
//  HomeViewModel.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    //@Published var emptyClass: Class = Class(name: "", professor: "", location: "", color: CodableColor(Color(.systemBackground)))
    @Published var selectedCity: String = ""
    @Published var selectedStay: String = ""
    
    @Published var isShowingAccountView: Bool = false
    @Published var isShowingTravelersView: Bool = false
}
