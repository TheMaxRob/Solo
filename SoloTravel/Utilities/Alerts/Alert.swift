//
//  Alert.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    
    // MARK: Data Alerts
    static let invalidData          = AlertItem(title: Text("Server Error"),
                                                message: Text("The data received from the server was invalid. Please contact support."),
                                                dismissButton: .default(Text("OK")))
    
    static let invalidResponse      = AlertItem(title: Text("Server Error"),
                                                message: Text("Invalid response from the server. Please try again later."),
                                                dismissButton: .default(Text("OK")))
    
    static let invalidURL           = AlertItem(title: Text("Server Error"),
                                                message: Text("There was an issue connecting with the server. If this persists, please contact support."),
                                                dismissButton: .default(Text("OK")))
    
    static let unableToComplete     = AlertItem(title: Text("Server Error"),
                                                message: Text("Unable to complete your request at this time. Please check your internet connection"),
                                                dismissButton: .default(Text("OK")))
    
    // MARK: Account Alerts
    
    static let invalidForm          = AlertItem(title: Text("Invalid Form"),
                                                message: Text("Please ensure all fields have been filled out."),
                                                dismissButton: .default(Text("OK")))
    
    static let invalidEmail         = AlertItem(title: Text("Invalid Email"),
                                                message: Text("Please ensure your email is correct."),
                                                dismissButton: .default(Text("OK")))
    
    static let userSaveSuccess      = AlertItem(title: Text("Profile Saved"),
                                                message: Text("Your profile information was successfully saved."),
                                                dismissButton: .default(Text("Done")))
    
    static let invalidUserData      = AlertItem(title: Text("Profile Error"), message: Text("There was an error saving or retrieving your profile. Please try again later."), dismissButton: .default(Text("OK")))
    
    
}

