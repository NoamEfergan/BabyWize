//
//  Constants.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import SwiftUI

// MARK: - Constants
public enum Constants: String {
    case preferredUnit
    case preferredUnitSolids

    case savedFeed = "SavedFeed"
    case savedSleep = "SavedSleep"
    case savedChange = "SavedNappyChange"
    case chartConfiguration
}

// MARK: - UserConstants
public enum UserConstants {
    public static let isLoggedIn = "IsLoggedIn"
    public static let hasAccount = "HasAccount"
    public static let userID = "UserID"
    public static let sharedIDs = "SharedIDs"
    public static let email = "email"
    public static let hasTimerRunning = "timerRunning"
    public static let hasFeedTimerRunning = "feedTimerRunning"
    public static let sleepStartTime = "sleepStart"
    public static let feedStartTime = "feedStart"
    public static let initialInstallDate = "initialInstall"
    public static let hasAskedForReview = "askedForReview"
}

// MARK: - GenericNetworkResponse
public enum GenericNetworkResponse {
    case succsess
    case fail(msg: String)
}

// MARK: - AppColours
public enum AppColours {
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

    static let tintPurple = Color(hex: "#5354EC")
}
