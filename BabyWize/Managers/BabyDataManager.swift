//
//  BabyDataManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//
import CoreData
import SwiftUI

final class BabyDataManager: ObservableObject {
    // MARK: - Private variables

    private let coreDataManager = BabyCoreDataManager()

    // MARK: - Exposed variables

    @Published var sleepData: [Sleep] = []
    @Published var feedData: [Feed] = []
    @Published var nappyData: [NappyChange] = []

    init() {
        fetchSavedValues()
    }

    // MARK: - Public methods

    func getLast(for type: EntryType) -> String {
        defer {
            self.objectWillChange
        }
        let notAvailable = "N/A"
        switch type {
        case .feed:
            guard let lastItem = feedData.last else { return notAvailable }
            return lastItem.solidOrLiquid == .liquid
            ? lastItem.amount.liquidFeedDisplayableAmount()
            : lastItem.amount.description
            
        case .sleep:
            return sleepData.last?.duration.convertToTimeInterval().displayableString ?? notAvailable
        case .nappy:
            guard let lastNappy = nappyData.last else {
                return notAvailable
            }
            return "\(lastNappy.dateTime.formatted(date: .omitted, time: .shortened)), \(lastNappy.wetOrSoiled.rawValue) "
        }
    }

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
            if let max = feedData.max(by: { $0.amount < $1.amount })?.amount.liquidFeedDisplayableAmount().description {
                return max
            } else {
                return "None found"
            }
        case .sleep:
            return sleepData.max(by: { $0.duration < $1.duration })?.duration ?? "None found"
        case .nappy:
            return ""
        }
    }

    func getSmallest(for type: EntryType) -> String {
        switch type {
        case .feed:
            if let min = feedData
                .min(by: { $0.amount < $1.amount })?
                .amount
                .liquidFeedDisplayableAmount()
                .description {
                return min
            } else {
                return "None found"
            }
        case .sleep:
            return sleepData.min(by: { $0.duration < $1.duration })?.duration ?? "None found"
        case .nappy:
            return ""
        }
    }

    // MARK: - CRUD methods

    // ADD
    func addFeed(_ item: Feed) {
        // Make sure we store feeds as ML, and do the conversion later
        let itemWithML = Feed(id: item.id,
                              date: item.date,
                              amount: item.solidOrLiquid == .liquid ? item.amount.convertToML() : item.amount,
                              note: item.note,
                              solidOrLiquid: item.solidOrLiquid)
        feedData.append(itemWithML)
        FirebaseManager().addFeed(itemWithML)
        coreDataManager.addFeed(itemWithML)
    }

    func addSleep(_ item: Sleep) {
        sleepData.append(item)
        coreDataManager.addSleep(item)
    }

    func addNappyChange(_ item: NappyChange) {
        nappyData.append(item)
        coreDataManager.addNappyChange(item)
    }

    // Update

    func updateFeed(_ item: Feed, index: Array<Feed>.Index) {
        feedData[index] = item
        coreDataManager.updateFeed(item)
    }

    func updateSleep(_ item: Sleep, index: Array<Sleep>.Index) {
        sleepData[index] = item
        coreDataManager.addSleep(item)
    }

    func updateChange(_ item: NappyChange, index: Array<NappyChange>.Index) {
        nappyData[index] = item
        coreDataManager.updateChange(item)
    }

    // Remove

    func removeFeed(at offsets: IndexSet) {
        let localFeeds = offsets.compactMap { feedData[$0] }
        coreDataManager.removeFeed(localFeeds)
        feedData.remove(atOffsets: offsets)
    }

    func removeSleep(at offsets: IndexSet) {
        let localSleeps = offsets.compactMap { sleepData[$0] }
        coreDataManager.removeSleep(localSleeps)
        sleepData.remove(atOffsets: offsets)
    }

    func removeChange(at offsets: IndexSet) {
        let localChanges = offsets.compactMap { nappyData[$0] }
        coreDataManager.removeChange(localChanges)
        nappyData.remove(atOffsets: offsets)
    }

    // MARK: - Private methods

    private func getAverageFeed() -> String {
        let totalAmount = feedData.reduce(0) { $0 + $1.amount }
        return (totalAmount / Double(feedData.count)).liquidFeedDisplayableAmount().description
    }

    private func getAverageSleepDuration() -> String {
        let totalAmount = sleepData.reduce(0) { $0 + $1.duration.convertToTimeInterval() }
        return (totalAmount / Double(sleepData.count)).hourMinuteSecondMS
    }

    private func fetchSavedValues() {
        feedData = coreDataManager.fetchFeeds()
        sleepData = coreDataManager.fetchSleeps()
        nappyData = coreDataManager.fetchChanges()
    }
}
