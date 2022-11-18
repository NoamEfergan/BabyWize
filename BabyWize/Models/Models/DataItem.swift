//
//  DataItem.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import SwiftUI

// MARK: - DataItem
protocol DataItem: Codable, Hashable, Identifiable {
    var id: String { get }
}

// MARK: - NappyChange
struct NappyChange: DataItem {
    let id: String
    let dateTime: Date
    let wetOrSoiled: WetOrSoiled

    enum WetOrSoiled: String, Codable, CaseIterable {
        case wet, soiled
    }
}

// MARK: - Sleep
struct Sleep: DataItem {
    let id: String
    let date: Date
    let start: Date
    let end: Date

    func getTimeInterval() -> TimeInterval {
        end.timeIntervalSince(start)
    }

    func getDuration() -> String {
        getTimeInterval().hourMinuteSecondMS
    }

    func getDisplayableString() -> String {
        getTimeInterval().displayableString
    }
}

// MARK: - Feed
struct Feed: DataItem {
    let id: String
    let date: Date
    var amount: Double
    let note: String?
    let solidOrLiquid: SolidOrLiquid

    enum SolidOrLiquid: String, Codable, CaseIterable {
        case solid, liquid
    }

    var isLiquids: Bool {
        solidOrLiquid == .liquid
    }

    var isSolids: Bool {
        solidOrLiquid == .solid
    }
}
