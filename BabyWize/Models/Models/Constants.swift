//
//  Constants.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation

// MARK: - Constants
enum Constants: String {
    case preferredUnit
    case preferredUnitSolids

    case savedFeed = "SavedFeed"
    case savedSleep = "SavedSleep"
    case savedChange = "SavedNappyChange"
    case chartConfiguration
}

// MARK: - UserConstants
enum UserConstants {
    static let isLoggedIn = "IsLoggedIn"
    static let hasAccount = "HasAccount"
    static let userID = "UserID"
    static let sharedIDs = "SharedIDs"
    static let email = "email"
}

// MARK: - GenericNetworkResponse
enum GenericNetworkResponse {
    case succsess
    case fail(msg: String)
}
