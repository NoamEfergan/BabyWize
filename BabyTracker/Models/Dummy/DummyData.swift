//
//  DummyData.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

enum DummyData {
    static let dummyFeed: [Feed] = [
        .init(id: UUID().uuidString, date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: UUID().uuidString, date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: UUID().uuidString, date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: UUID().uuidString, date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
    ]

    static let dummySleeps: [Sleep] = [
        .init(id: UUID().uuidString, date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
        .init(id: UUID().uuidString, date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
        .init(id: UUID().uuidString, date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
        .init(id: UUID().uuidString, date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
    ]
}
