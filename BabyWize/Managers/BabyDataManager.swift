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
        switch type {
        case .liquidFeed, .solidFeed:
            guard let lastItem = feedData.last else {
                return .nonAvailable
            }
            return lastItem.amount.displayableAmount(isSolid: lastItem.isSolids)
        case .sleep:
            return sleepData.last?.duration.convertToTimeInterval().displayableString ?? .nonAvailable
        case .nappy:
            guard let lastNappy = nappyData.last else {
                return .nonAvailable
            }
            return "\(lastNappy.dateTime.formatted(date: .omitted, time: .shortened)), \(lastNappy.wetOrSoiled.rawValue) "
        }
    }

    func getAverage(for type: EntryType) -> String {
        switch type {
        case .liquidFeed:
            return getAverageFeed(isSolid: false)
        case .solidFeed:
            return getAverageFeed(isSolid: true)
        case .sleep:
            return getAverageSleepDuration()
        case .nappy:
            // TODO: Make this
            return "Something"
        }
    }

    func getBiggest(for type: EntryType) -> String {
        switch type {
        case .liquidFeed:
            if let max = feedData
                .filter(\.isLiquids)
                .max(by: { $0.amount < $1.amount })?
                .amount.liquidFeedDisplayableAmount() {
                return max
            } else {
                return .nonAvailable
            }

        case .solidFeed:
            if let max = feedData
                .filter(\.isSolids)
                .max(by: { $0.amount < $1.amount })?
                .amount.solidFeedDisplayableAmount() {
                return max
            } else {
                return .nonAvailable
            }
        case .sleep:
            return sleepData.max(by: { $0.duration < $1.duration })?.duration ?? .nonAvailable
        case .nappy:
            return ""
        }
    }

    func getSmallest(for type: EntryType) -> String {
        switch type {
        case .liquidFeed:
            if let min = feedData
                .filter(\.isLiquids)
                .min(by: { $0.amount < $1.amount })?
                .amount
                .liquidFeedDisplayableAmount() {
                return min
            } else {
                return .nonAvailable
            }

        case .solidFeed:
            if let min = feedData
                .filter(\.isSolids)
                .min(by: { $0.amount < $1.amount })?
                .amount
                .solidFeedDisplayableAmount() {
                return min
            } else {
                return .nonAvailable
            }
        case .sleep:
            return sleepData.min(by: { $0.duration < $1.duration })?.duration ?? .nonAvailable
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

    private func getAverageFeed(isSolid: Bool) -> String {
        let data = isSolid ? feedData.filter(\.isSolids) : feedData.filter(\.isLiquids)
        let totalAmount = data.reduce(0) { $0 + $1.amount }
        return (totalAmount / Double(data.count)).displayableAmount(isSolid: isSolid)
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
