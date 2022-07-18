//
//  SleepManager.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

final class SleepManager: NSObject, DataManager {
    @Published var data: [Sleep] = []

    override init() {
        super.init()
        self.data = fetchData()
    }

    func fetchData() -> [Sleep] {
        DummyData.dummySleeps.sorted(by: { $0.date < $1.date })
    }
}

final class FeedManager: NSObject, DataManager {
    @Published var data: [Feed] = []

    override init() {
        super.init()
        self.data = fetchData()
    }

    func fetchData() -> [Feed] {
        DummyData.dummyFeed.sorted(by: { $0.date < $1.date })
    }
}

final class NappyManager: NSObject, DataManager {
    @Published var data: [NappyChange] = []

    override init() {
        super.init()
        self.data = fetchData()
    }

    func fetchData() -> [NappyChange] {
        []
    }
}
