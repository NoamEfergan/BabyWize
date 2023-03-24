//
//  MockEntries.swift
//  BabyWize
//
//  Created by Noam Efergan on 24/03/2023.
//

import Foundation

// MARK: - MockEntries
enum MockEntries {
    static var mockFeed: [Feed] { [
        Feed(id: "1",
             date: Date.getRandomMockDate(),
             amount: 100,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.solid),
        Feed(id:"2",
             date: Date.getRandomMockDate(),
             amount: 120,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.solid),
        Feed(id: "3",
             date: Date.getRandomMockDate(),
             amount: 130,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid),
        Feed(id: "4",
             date: Date.getRandomMockDate(),
             amount: 120,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid),
        Feed(id: "5",
             date: Date.getRandomMockDate(),
             amount: 110,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid),
        Feed(id: "6",
             date: Date.getRandomMockDate(),
             amount: 150,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid)
    ]
    .sorted(by: { $0.date < $1.date })
    }

    static var mockBreast: [BreastFeed] {
        let firstStart = Date.getRandomMockDate()
        let secondStart = Date.getRandomMockDate()
        let thirdStart = Date.getRandomMockDate()

        let firstEnd = Date.getRandomEndData(from: firstStart)
        let secondEnd = Date.getRandomEndData(from: secondStart)
        let thirdEnd = Date.getRandomEndData(from: thirdStart)

        return [
            BreastFeed(id: UUID().uuidString,
                       date: Date.getRandomMockDate(),
                       start: firstStart,
                       end:firstEnd),
            BreastFeed(id: UUID().uuidString,
                       date: Date.getRandomMockDate(),
                       start: secondStart,
                       end:secondEnd),
            BreastFeed(id: UUID().uuidString,
                       date: Date.getRandomMockDate(),
                       start: thirdStart,
                       end:thirdEnd),
        ].sorted(by: { $0.date < $1.date })
    }

    static var mockSleep: [Sleep] {
        let firstStart = Date.getRandomMockDate()
        let secondStart = Date.getRandomMockDate()
        let thirdStart = Date.getRandomMockDate()

        let firstEnd = Date.getRandomEndData(from: firstStart)
        let secondEnd = Date.getRandomEndData(from: secondStart)
        let thirdEnd = Date.getRandomEndData(from: thirdStart)

        return [
            Sleep(id: UUID().uuidString,
                  date: Date.getRandomMockDate(),
                  start: firstStart,
                  end:firstEnd),
            Sleep(id: UUID().uuidString,
                  date: Date.getRandomMockDate(),
                  start: secondStart,
                  end:secondEnd),
            Sleep(id: UUID().uuidString,
                  date: Date.getRandomMockDate(),
                  start: thirdStart,
                  end:thirdEnd),
        ].sorted(by: { $0.date < $1.date })
    }
}
