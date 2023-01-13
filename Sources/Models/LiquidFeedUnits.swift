//
//  FeedUnits.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import SwiftUI

// MARK: - LiquidFeedUnits
public enum LiquidFeedUnits: String,Hashable, CaseIterable {
    case ml
    case ozUS = "oz (us)"
    case oz

    public var title: String {
        switch self {
        case .ml:
            return "ml"
        case .ozUS, .oz:
            return "oz"
        }
    }
}

// MARK: - SolidFeedUnits
public enum SolidFeedUnits: String, CaseIterable {
    case grams
    case oz

    public var title: String {
        switch self {
        case .grams:
            return "g"
        case .oz:
            return "oz"
        }
    }
}
