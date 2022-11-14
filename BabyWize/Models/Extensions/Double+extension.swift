//
//  Double+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import Swinject

extension Double {
    static func getRandomFeedAmount() -> Double {
        Self.random(in: 100.0 ..< 250.0)
    }

    func roundDecimalPoint(to places: Int = 2) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func convertLiquids(from: LiquidFeedUnits, to unit: LiquidFeedUnits) -> Self{
        guard from != unit else {
            return self
        }
        switch from {
        case .ml:
            return  convertML(to: unit)
        case .ozUS:
            return  convertUSOz(to: unit)
        case .oz:
            return  convertOZ(to: unit)
        }
    }

    private func convertML(to unit: LiquidFeedUnits) -> Self {
        switch unit {
        case .ml:
            return roundDecimalPoint()
        case .ozUS:
            return (self * 0.033814).roundDecimalPoint()
        case .oz:
            return (self * 0.0351951).roundDecimalPoint()
        }
    }

    private func convertOZ(to unit: LiquidFeedUnits) -> Self {
        switch unit {
        case .ml:
            return (self / 0.0351951).roundDecimalPoint()
        case .ozUS:
            return (self * 0.96).roundDecimalPoint()
        case .oz:
            return roundDecimalPoint()
        }
    }

    private func convertUSOz(to unit: LiquidFeedUnits) -> Self {
        switch unit {
        case .ml:
            return (self * 29.5735).roundDecimalPoint()
        case .ozUS:
            return roundDecimalPoint()
        case .oz:
            return (self / 0.96).roundDecimalPoint()
        }
    }

    func displayableAmount(isSolid: Bool) -> String {
        isSolid ? solidFeedDisplayableAmount() : liquidFeedDisplayableAmount()
    }

    func solidFeedDisplayableAmount() -> String {
        @InjectedObject var unitsManager: UnitsManager
        switch unitsManager.solidUnits {
        case .grams:
            return "\(roundDecimalPoint().description) \(unitsManager.solidUnits.title)"
        }
    }

    func liquidFeedDisplayableAmount() -> String {
        @InjectedObject var unitsManager: UnitsManager
        return roundDecimalPoint().description + unitsManager.liquidUnits.title
    }
}

extension TimeInterval {
    var displayableString: String {
        let hoursString = hour > 1 ? " hrs" : " hour"
        let minuteString = minute > 1 ? "mins" : "min"
        let separator = minute > 0 ? ",\n" : ""
        let hourDisplayable = hour > 0 ? hour.description + hoursString : ""
        let minutesDisplayable = minute > 0 ? minute.description + minuteString : ""
        return "\(hourDisplayable)\(separator)\(minutesDisplayable)"
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
