//
//  Double+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import Swinject

public extension Double {
    static func getRandomFeedAmount() -> Double {
        Self.random(in: 100.0 ..< 250.0)
    }

    func roundDecimalPoint(to places: Int = 2) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func convertLiquids(from: LiquidFeedUnits, to unit: LiquidFeedUnits) -> Self {
        guard from != unit else {
            return self
        }
        switch from {
        case .ml:
            return convertML(to: unit)
        case .ozUS:
            return convertUSOz(to: unit)
        case .oz:
            return convertLiquidOZ(to: unit)
        }
    }

    func convertSolids(from: SolidFeedUnits, to unit: SolidFeedUnits) -> Self {
        guard from != unit else {
            return self
        }
        switch from {
        case .grams:
            return convertGrams(to: unit)
        case .oz:
            return convertMassOz(to: unit)
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

    private func convertLiquidOZ(to unit: LiquidFeedUnits) -> Self {
        switch unit {
        case .ml:
            return (self / 0.0351951).roundDecimalPoint()
        case .ozUS:
            return (self * 0.96).roundDecimalPoint()
        case .oz:
            return roundDecimalPoint()
        }
    }

    private func convertMassOz(to unit: SolidFeedUnits) -> Self {
        switch unit {
        case .grams:
            return (self * 28.35).roundDecimalPoint()
        case .oz:
            return roundDecimalPoint()
        }
    }

    private func convertGrams(to unit: SolidFeedUnits) -> Self {
        switch unit {
        case .grams:
            return roundDecimalPoint()
        case .oz:
            return (self / 28.35).roundDecimalPoint()
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
        var unit: SolidFeedUnits {
            if let savedSolid = UserDefaults.standard.string(forKey: Constants.preferredUnitSolids.rawValue) {
                return .init(rawValue: savedSolid) ?? .grams
            } else {
                return .grams
            }
        }
        return "\(roundDecimalPoint().description) \(unit.title)"
    }

    func liquidFeedDisplayableAmount() -> String {
        var unit: LiquidFeedUnits {
            if let savedLiquid = UserDefaults.standard.string(forKey: Constants.preferredUnit.rawValue) {
                return .init(rawValue: savedLiquid) ?? .ml
            } else {
                return .ml
            }
        }
        return roundDecimalPoint().description + unit.title
    }
}
