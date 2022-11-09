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

    init() {
        if let savedString = UserDefaults.standard.string(forKey: Constants.preferredUnit.rawValue) {
            liquidUnits = .init(rawValue: savedString) ?? .ml
        } else {
            liquidUnits = .ml
        }
    }
}
