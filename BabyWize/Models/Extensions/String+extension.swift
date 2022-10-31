//
//  String+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 30/10/2022.
//
import Foundation
extension String {
    func convertToTimeInterval() -> TimeInterval {
        guard self != "" else {
            return 0
        }
        var interval: Double = 0
        let parts = components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        return interval
    }
}
