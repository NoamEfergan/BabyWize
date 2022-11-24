//
//  UserDefaultManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 09/11/2022.
//

import SwiftUI

final class UserDefaultManager: ObservableObject {
    @Published var chartConfiguration: ChartConfiguration {
        didSet {
            UserDefaults.standard.set(chartConfiguration.rawValue, forKey: Constants.chartConfiguration.rawValue)
        }
    }

    @Published var liquidUnits: LiquidFeedUnits {
        didSet {
            UserDefaults.standard.set(liquidUnits.rawValue, forKey: Constants.preferredUnit.rawValue)
        }
    }

    @Published var solidUnits: SolidFeedUnits {
        didSet {
            UserDefaults.standard.set(solidUnits.rawValue, forKey: Constants.preferredUnitSolids.rawValue)
        }
    }

    var hasAccount: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserConstants.hasAccount)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.hasAccount)
        }
    }

    var isLoggedIn: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserConstants.isLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.isLoggedIn)
        }
    }

    var sharingAccounts: [SharingAccount] {
        get {
            if let data = UserDefaults.standard.data(forKey: UserConstants.sharedIDs),
               let decodedValue = try? JSONDecoder().decode([SharingAccount].self, from: data) {
                return decodedValue
            } else {
                return []
            }
        }
        set {
            if let encodedValue = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedValue, forKey: UserConstants.sharedIDs)
            }
        }
    }

    func addNewSharingAccount(_ account: SharingAccount) {
        if let index = sharingAccounts.enumerated().first(where: { $0.element.id == account.id }) {
            sharingAccounts[index.offset] = account
        } else {
            sharingAccounts.append(account)
        }
    }

    var userID: String? {
        get {
            UserDefaults.standard.string(forKey: UserConstants.userID)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.userID)
        }
    }

    var email: String? {
        get {
            UserDefaults.standard.string(forKey: UserConstants.email)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserConstants.email)
        }
    }

    init() {
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
