//
//  UnitsManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 09/11/2022.
//

import SwiftUI

final class UnitsManager: ObservableObject {
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
    }
}
