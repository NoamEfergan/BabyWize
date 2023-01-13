//
//  EntryType.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

public enum EntryType: String, CaseIterable, Hashable {
    case liquidFeed, sleep, nappy, solidFeed, breastFeed

    public var title: String {
        switch self {
        case .liquidFeed, .solidFeed:
            return "Feed"
        case .sleep:
            return "Sleep"
        case .nappy:
            return "Nappy"
        case .breastFeed:
            return "Breast Feed"
        }
    }
}
