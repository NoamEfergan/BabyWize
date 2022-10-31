//
//  Double+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

extension Double {
    static func getRandomFeedAmount() -> Double {
        Self.random(in: 100.0 ..< 250.0)
    }

    func roundDecimalPoint(to places: Int = 2) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func feedDisplayableAmount() -> String {
        let userPreferredUnit: FeedUnits = .init(
            rawValue: UserDefaults.standard.string(forKey: Constants.preferredUnit.rawValue) ?? ""
        ) ?? .ml
        switch userPreferredUnit {
        case .ml:
            return description + userPreferredUnit.rawValue
        case .ozUS:
            return (self / 29.574).description + userPreferredUnit.rawValue
        case .oz:
            return (self / 28.413).description + userPreferredUnit.rawValue
        }
    }
}

extension TimeInterval {
    var displayableString: String {
        let hoursString = hour > 1 ? " hrs" : " hour"
        let minuteString = minute > 1 ? " mins" : " min"
        let separator = minute > 0 ? "," : ""
        let hourDisplayable = hour > 0 ? hour.description + hoursString : ""
        let minutesDisplayable = minute > 0 ? minute.description + minuteString : ""
        return "\(hourDisplayable)\(separator) \(minutesDisplayable)"
    }

    var hourMinuteSecondMS: String {
        String(format: "%d:%02d:%02d", hour, minute, second)
    }

    var minuteSecondMS: String {
        String(format: "%d:%02d.%03d", minute, second, millisecond)
    }

    var hour: Int {
        Int((self / 3600).truncatingRemainder(dividingBy: 3600))
    }

    var minute: Int {
        Int((self / 60).truncatingRemainder(dividingBy: 60))
    }

    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }

    var millisecond: Int {
        Int((self * 1000).truncatingRemainder(dividingBy: 1000))
    }
}
