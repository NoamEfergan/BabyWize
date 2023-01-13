//
//  DataItem.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import SwiftUI

// MARK: - DataItem
public protocol DataItem: Codable, Hashable, Identifiable {
    var id: String { get }
}

// MARK: - NappyChange
public struct NappyChange: DataItem {
    public let id: String
    public let dateTime: Date
    public let wetOrSoiled: WetOrSoiled

    public enum WetOrSoiled: String, Codable, CaseIterable {
        case wet, soiled
    }

    public init(id: String, dateTime: Date, wetOrSoiled: WetOrSoiled) {
        self.id = id
        self.dateTime = dateTime
        self.wetOrSoiled = wetOrSoiled
    }
}

// MARK: - Sleep
public struct Sleep: DataItem {
    public let id: String
    public let date: Date
    public let start: Date
    public let end: Date

    public init(id: String, date: Date, start: Date, end: Date) {
        self.id = id
        self.date = date
        self.start = start
        self.end = end
    }

    public func getTimeInterval() -> TimeInterval {
        end.timeIntervalSince(start)
    }

    public func getDuration() -> String {
        getTimeInterval().hourMinuteSecondMS
    }

    public func getDisplayableString() -> String {
        getTimeInterval().displayableString
    }
}

// MARK: - Feed
public struct Feed: DataItem {
    public let id: String
    public let date: Date
    public var amount: Double
    public let note: String?
    public let solidOrLiquid: SolidOrLiquid

    public init(id: String, date: Date, amount: Double, note: String?, solidOrLiquid: SolidOrLiquid) {
        self.id = id
        self.date = date
        self.amount = amount
        self.note = note
        self.solidOrLiquid = solidOrLiquid
    }

    public enum SolidOrLiquid: Codable, Equatable, Hashable, CaseIterable, Identifiable {
        public var id: Self { self }
        case solid
        case liquid

        public var title: String {
            switch self {
            case .solid:
                return "Solid"
            case .liquid:
                return "Liquid"
            }
        }
    }

    public var isLiquids: Bool {
        solidOrLiquid != .solid
    }

    public var isSolids: Bool {
        solidOrLiquid == .solid
    }
}

// MARK: - BreastFeed
public struct BreastFeed: DataItem {
    public let id: String
    public let date: Date
    public let start: Date
    public let end: Date

    public init(id: String, date: Date, start: Date, end: Date) {
        self.id = id
        self.date = date
        self.start = start
        self.end = end
    }

    public func getTimeInterval() -> TimeInterval {
        end.timeIntervalSince(start)
    }

    public func getDuration() -> String {
        getTimeInterval().hourMinuteSecondMS
    }

    public func getDisplayableString() -> String {
        getTimeInterval().displayableString
    }
}
