//
//  DummyData.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

enum DummyData {
    static let dummyFeed: [Feed] = [
        .init(id: "1", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "2", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "3", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "4", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "5", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "6", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "7", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "8", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
        .init(id: "9", date: .getRandomMockDate(), amount: .getRandomFeedAmount()),
    ]

    static let dummySleeps: [Sleep] = [
        .init(id: "1", date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
        .init(id: "2", date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
        .init(id: "3", date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
        .init(id: "4", date: .getRandomMockDate(), duration: Double.getRandomFeedAmount().hourMinuteSecondMS),
    ]
}
