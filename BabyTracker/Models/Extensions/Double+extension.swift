//
//  Double+extension.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

extension Double {
    static func getRandomFeedAmount() -> Double {
        Self.random(in: 100.0 ..< 180.0)
    }

    func convertDurationToString() -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date(timeInterval: TimeInterval(self), since: .getRandomMockDate()))
        var hour: String {
            guard let hoursPassed = components.hour else { return "" }
            return hoursPassed > 1 ? "\(hoursPassed) hours " : "\(hoursPassed) hour "
        }
        var minutes: String {
            guard let minutesPassed = components.minute else { return "" }
            return minutesPassed > 1 ? "\(minutesPassed) minute" : "\(minutesPassed) minutes"
        }

        return "\(hour)\(minutes)"
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
            return self.description
        case .ozUS:
            return (self / 29.574).description
        case .oz:
            return (self / 28.413).description
        }
    }
}
