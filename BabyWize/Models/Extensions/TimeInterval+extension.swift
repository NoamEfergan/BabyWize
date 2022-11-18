//
//  TimeInterval+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/11/2022.
//

import Foundation
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
