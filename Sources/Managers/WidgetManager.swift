//
//  WidgetManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/07/2022.
//

import Foundation
import WidgetKit
import Models

public struct WidgetManager {
    @Inject private var dataManager: BabyDataManager
    static let suiteName = "group.babyData"

    public init() {}

    public func setLatest() {
        let lastFeed = dataManager.lastFeedString
        let lastSleep = dataManager.lastSleepString
        let lastNappy = dataManager.lastChangeString

        guard let container = UserDefaults(suiteName: Self.suiteName) else {
            return
        }
        container.set(lastFeed, forKey: "lastFeed")
        container.set(lastSleep, forKey: "lastSleep")
        container.set(lastNappy, forKey: "lastNappy")

        WidgetCenter.shared.reloadAllTimelines()
    }
}
