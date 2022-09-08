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
    
    // MARK: - CRUD methods

    func addFeed(_ item: Feed) {
        feedData.append(item)
        item.mapToSavedFeed(context: moc)
        try? moc.save()
    }

    func addSleep(_ item: Sleep) {
        sleepData.append(item)
        item.mapToSavedSleep(context: moc)
        try? moc.save()
    }

    func addNappyChange(_ item: NappyChange) {
        nappyData.append(item)
        item.mapToSavedChange(context: moc)
        try? moc.save()
    }
    
    func updateFeed(_ item: Feed, index: Array<Feed>.Index) {
        feedData[index] = item
        let savedFeeds = try? moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed]
        let relevantFeed = savedFeeds?.first(where: { $0.id == item.id })
        relevantFeed?.date = item.date
        relevantFeed?.amount = item.amount
        try? moc.save()
    }
    
    func updateSleep(_ item: Sleep, index: Array<Sleep>.Index) {
        sleepData[index] = item
        let savedSleeps = try? moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]
        let relevantSleep = savedSleeps?.first(where:  { $0.id == item.id } )
        relevantSleep?.date = item.date
        relevantSleep?.duration = item.duration
        try? moc.save()
    }
    
    func updateChange( _ item: NappyChange, index: Array<NappyChange>.Index) {
        nappyData[index] = item
        let savedChanges = try? moc.fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]
        let relevantChange = savedChanges?.first(where:  { $0.id == item.id})
        relevantChange?.dateTime = item.dateTime
        try? moc.save()
    }

    // MARK: - Private methods

    private func getAverageFeed() -> String {
        let totalAmount = feedData.reduce(0) { $0 + $1.amount }
        return (totalAmount / Double(feedData.count)).roundDecimalPoint().description
    }

    private func getAverageSleepDuration() -> String {
        let totalAmount = sleepData.reduce(0) { $0 + $1.duration.convertToTimeInterval() }
        return (totalAmount / Double(sleepData.count)).hourMinuteSecondMS
    }

    private func fetchSavedValues() {
        let savedFeeds = try? moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed]
        let savedSleeps = try? moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]
        let savedChanges = try? moc.fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]

        if let savedFeeds {
            feedData = savedFeeds.compactMap { $0.mapToFeed() }
        }

        if let savedSleeps {
            sleepData = savedSleeps.compactMap { $0.mapToSleep() }
        }

        if let savedChanges {
            nappyData = savedChanges.compactMap { $0.mapToNappyChange() }
        }
    }
}
