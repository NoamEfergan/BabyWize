//
//  Constants.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import SwiftUI

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
    static let hasTimerRunning = "timerRunning"
    static let sleepStartTime = "sleepStart"
}

// MARK: - GenericNetworkResponse
enum GenericNetworkResponse {
    case succsess
    case fail(msg: String)
}

// MARK: - AppColours
enum AppColours {
    public static let gradient: LinearGradient = .init(colors: [
        .init(hex: "#F5C0A7"),
        .init(hex: "#F2AAA2"),
        .init(hex: "#F0969E"),
        .init(hex: "#EE829A")
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing)

    public static let errorGradient: LinearGradient = .init(colors: [
        .init(hex: "#EB4E3E"),
        .init(hex: "#FF6F76"),
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing)

    public static let secondary: LinearGradient = .init(colors: [
        .secondary
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing)
}
