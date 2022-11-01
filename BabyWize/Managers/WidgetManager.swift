//
//  WidgetManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/07/2022.
//

import Foundation
import WidgetKit

struct WidgetManager {
    @Inject private var dataManager: BabyDataManager
    static let suiteName = "group.babyData"

    func setLatest() {
        let lastFeed = dataManager.feedData.last
        let lastSleep = dataManager.sleepData.last
        let lastNappy = dataManager.nappyData.last

        guard let container = UserDefaults(suiteName: Self.suiteName) else {
            return
        }
        if let lastFeed {
            container.set(lastFeed.amount.roundDecimalPoint().feedDisplayableAmount(), forKey: "lastFeed")
        }
        if let lastSleep {
            container.set(lastSleep.duration, forKey: "lastSleep")
        }
        if let lastNappy {
            container.set(lastNappy.dateTime, forKey: "lastNappy")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }
}
