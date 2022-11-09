//
//  FeedUnits.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import SwiftUI

enum LiquidFeedUnits: String, CaseIterable {
    case ml
    case ozUS = "oz (us)"
    case oz
    
    var title: String {
        switch self {
        case .ml:
            return "ml"
        case .ozUS, .oz:
            return "oz"
        }
    }
}
