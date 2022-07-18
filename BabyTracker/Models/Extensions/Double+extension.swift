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
}
