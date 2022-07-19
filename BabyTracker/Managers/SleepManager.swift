//
//  SleepManager.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

final class SleepManager: DataManager {
    @Published var data: [Sleep] = []

    init() {
        self.data = fetchData()
    }

    func fetchData() -> [Sleep] {
        DummyData.dummySleeps.sorted(by: { $0.date < $1.date })
    }
}

final class FeedManager: DataManager {
    @Published var data: [Feed] = []

    init() {
        self.data = fetchData()
    }

    func fetchData() -> [Feed] {
        DummyData.dummyFeed.sorted(by: { $0.date < $1.date })
    }
}

final class NappyManager: DataManager {
    @Published var data: [NappyChange] = []

    init() {
        self.data = fetchData()
    }

    func fetchData() -> [NappyChange] {
        [.init(id: UUID().uuidString, dateTime: .now)]
    }
}
