//
//  BabyDataManager.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

final class BabyDataManager: ObservableObject {
    // MARK: - Exposed variables

    @Published var sleepData: [Sleep] = []
    @Published var feedData: [Feed] = []
    @Published var nappyData: [NappyChange] = []

    init() {
        feedData = fetchFeedData()
        sleepData = fetchSleepData()
        nappyData = fetchNappyData()
    }

    // MARK: - Public methods

    func getAverage(for type: EntryType) -> String {
        switch type {
        case .feed:
            return getAverageFeed()
        case .sleep:
            return getAverageSleepDuration()
        case .nappy:
            // TODO: Make this
            return "Something"
        }
    }

    func deleteItem(at offsets: IndexSet, for type: EntryType) {
        switch type {
        case .feed:
            feedData.remove(atOffsets: offsets)
        case .sleep:
            sleepData.remove(atOffsets: offsets)
        case .nappy:
            nappyData.remove(atOffsets: offsets)
        }
    }

    // MARK: - Private methods

    private func fetchSleepData() -> [Sleep] {
        DummyData.dummySleeps.sorted(by: { $0.date < $1.date })
    }

    private func fetchFeedData() -> [Feed] {
        DummyData.dummyFeed.sorted(by: { $0.date < $1.date })
    }

    private func fetchNappyData() -> [NappyChange] {
        [.init(id: "1", dateTime: .now)]
    }

    private func getAverageFeed() -> String {
        let totalAmount = feedData.reduce(0) { $0 + $1.amount }
        return (totalAmount / Double(feedData.count)).roundDecimalPoint().description
    }

    private func getAverageSleepDuration() -> String {
        let totalAmount = sleepData.reduce(0) { $0 + $1.duration.convertToTimeInterval() }
        return (totalAmount / Double(sleepData.count)).hourMinuteSecondMS
    }
}
