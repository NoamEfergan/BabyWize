//
//  EntryType.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

enum EntryType: String, CaseIterable, Hashable {
    case liquidFeed, sleep, nappy, solidFeed
    
    var title: String {
        switch self {
        case .liquidFeed, .solidFeed:
            return "Feed"
        case .sleep:
            return "Sleep"
        case .nappy:
            return "Nappy Change"
        }
    }
}
