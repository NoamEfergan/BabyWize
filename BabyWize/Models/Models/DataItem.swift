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

    enum SolidOrLiquid: Codable, Equatable, Hashable, CaseIterable, Identifiable {
        var id: Self { self }
        case solid
        case liquid

        var title: String {
            switch self {
            case .solid:
                return "Solid"
            case .liquid:
                return "Liquid"
            }
        }
    }

    var isLiquids: Bool {
        solidOrLiquid != .solid
    }

    var isSolids: Bool {
        solidOrLiquid == .solid
    }
}

// MARK: - BreastFeed
struct BreastFeed: DataItem {
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
