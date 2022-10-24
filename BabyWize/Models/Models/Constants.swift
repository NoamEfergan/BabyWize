//
//  Constants.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation

enum Constants: String {
    case preferredUnit

    case savedFeed = "SavedFeed"
    case savedSleep = "SavedSleep"
    case savedChange = "SavedNappyChange"
}

enum UserConstants {
    static let isLoggedIn = "IsLoggedIn"
    static let userName = "UserName"
    static let email = "Email"
}

enum GenericNetworkResponse {
    case succsess
    case fail(msg: String)
}
