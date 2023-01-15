//
//  UserDefaultManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 09/11/2022.
//

import SwiftUI
import Models

public final class UserDefaultManager: ObservableObject {
    @Published public var chartConfiguration: ChartConfiguration {
        didSet {
            UserDefaults.standard.set(chartConfiguration.rawValue, forKey: Constants.chartConfiguration.rawValue)
        }
    }

    @Published public var liquidUnits: LiquidFeedUnits {
        didSet {
            UserDefaults.standard.set(liquidUnits.rawValue, forKey: Constants.preferredUnit.rawValue)
        }
    }

    @Published public var solidUnits: SolidFeedUnits {
        didSet {
            UserDefaults.standard.set(solidUnits.rawValue, forKey: Constants.preferredUnitSolids.rawValue)
        }
    }

    @Published public var hasTimerRunning: Bool {
        didSet {
            UserDefaults.standard.set(hasTimerRunning, forKey: UserConstants.hasTimerRunning)
        }
    }

    @Published public var hasFeedTimerRunning: Bool {
        didSet {
            UserDefaults.standard.set(hasFeedTimerRunning, forKey: UserConstants.hasFeedTimerRunning)
        }
    }

    public var sleepStartDate: Date? {
        get {
            UserDefaults.standard.object(forKey: UserConstants.sleepStartTime) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.sleepStartTime)
        }
    }

    public var feedStartDate: Date? {
        get {
            UserDefaults.standard.object(forKey: UserConstants.feedStartTime) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.feedStartTime)
        }
    }

    public var hasAccount: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserConstants.hasAccount)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.hasAccount)
        }
    }

    public var isLoggedIn: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserConstants.isLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.isLoggedIn)
        }
    }

    @Published public var sharingAccounts: [SharingAccount]

    public func addNewSharingAccount(_ account: SharingAccount) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            if let index = self.sharingAccounts.enumerated().first(where: { $0.element.id == account.id }) {
                self.sharingAccounts[index.offset] = account
            } else {
                self.sharingAccounts.append(account)
                if let encodedValue = try? JSONEncoder().encode(self.sharingAccounts) {
                    UserDefaults.standard.set(encodedValue, forKey: UserConstants.sharedIDs)
                }
            }
        }
    }

    public func removeSharingAccount(with id: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.sharingAccounts = self.sharingAccounts.filter { $0.id != id }
            if let encodedValue = try? JSONEncoder().encode(self.sharingAccounts) {
                UserDefaults.standard.set(encodedValue, forKey: UserConstants.sharedIDs)
            }
        }
    }

    public var userID: String? {
        get {
            UserDefaults.standard.string(forKey: UserConstants.userID)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.userID)
        }
    }

    public var email: String? {
        get {
            UserDefaults.standard.string(forKey: UserConstants.email)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.email)
        }
    }

    public init() {
        if let savedLiquid = UserDefaults.standard.string(forKey: Constants.preferredUnit.rawValue) {
            liquidUnits = .init(rawValue: savedLiquid) ?? .ml
        } else {
            liquidUnits = .ml
        }


        if let savedSolid = UserDefaults.standard.string(forKey: Constants.preferredUnitSolids.rawValue) {
            solidUnits = .init(rawValue: savedSolid) ?? .grams
        } else {
            solidUnits = .grams
        }


        if let savedConfig = UserDefaults.standard.string(forKey: Constants.chartConfiguration.rawValue) {
            chartConfiguration = .init(rawValue: savedConfig) ?? .joint
        } else {
            chartConfiguration = .joint
        }

        if let data = UserDefaults.standard.data(forKey: UserConstants.sharedIDs),
           let decodedValue = try? JSONDecoder().decode([SharingAccount].self, from: data) {
            sharingAccounts = decodedValue
        } else {
            sharingAccounts = []
        }

        hasTimerRunning = UserDefaults.standard.bool(forKey: UserConstants.hasTimerRunning)
        hasFeedTimerRunning = UserDefaults.standard.bool(forKey: UserConstants.hasFeedTimerRunning)
    }

    public func logOut() {
        hasAccount = false
        userID = nil
        sharingAccounts = []
        isLoggedIn = false
        email = nil
    }

    public func signIn(with id: String, email: String) {
        hasAccount = true
        userID = id
        isLoggedIn = true
        self.email = email
    }
}
