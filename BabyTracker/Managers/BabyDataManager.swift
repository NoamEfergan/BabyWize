//
//  BabyDataManager.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import CoreData
import SwiftUI


final class BabyDataManager: ObservableObject {
    // MARK: - Private variables
    private var moc = DataController().container.viewContext

    // MARK: - Exposed variables

    @Published var sleepData: [Sleep] = []
    @Published var feedData: [Feed] = []
    @Published var nappyData: [NappyChange] = []

    init() {
        fetchSavedValues()
    }

    private func fetchSavedValues() {
        let savedFeeds = try? moc.fetch(.init(entityName: "SavedFeed")) as? [SavedFeed]
        let savedSleeps = try? moc.fetch(.init(entityName: "SavedSleep")) as? [SavedSleep]
        let savedChanges = try? moc.fetch(.init(entityName: "SavedNappyChange")) as? [SavedNappyChange]

        if let savedFeeds {
            feedData = savedFeeds.compactMap { $0.mapToFeed() }
        }

        if let savedSleeps {
            sleepData = savedSleeps.compactMap { $0.mapToSleep() }
        }
        
        if let savedChanges {
            nappyData = savedChanges.compactMap { $0.mapToNappyChange()}
        }
    }

    private func setAll() {
        try? moc.save()
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

    func getBiggest(for type: EntryType) -> String {
        switch type {
        case .feed:
            return feedData.max(by: { $0.amount < $1.amount })?.amount.roundDecimalPoint().description ?? "None found"
        case .sleep:
            return sleepData.max(by: { $0.duration < $1.duration })?.duration ?? "None found"
        case .nappy:
            return ""
        }
    }

    func getSmallest(for type: EntryType) -> String {
        switch type {
        case .feed:
            return feedData.min(by: { $0.amount < $1.amount })?.amount.roundDecimalPoint().description ?? "None found"
        case .sleep:
            return sleepData.min(by: { $0.duration < $1.duration })?.duration ?? "None found"
        case .nappy:
            return ""
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
