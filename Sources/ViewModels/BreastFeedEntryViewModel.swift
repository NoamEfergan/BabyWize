//
//  BreastFeedEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 02/01/2023.
//

import Foundation
import Models
import Managers

// MARK: - BreastFeedEntryViewModel
public final class BreastFeedEntryViewModel: EntryViewModel {
    @InjectedObject private var dataManager: BabyDataManager
    @Inject private var defaultManager: UserDefaultManager
    @Published public var startDate: Date = .init()
    @Published public var endDate: Date = .init()
    @Published public var selectedLiveOrOld: LiveOrOld = .Old

    public var itemID = ""

    public init() {
        selectedLiveOrOld = defaultManager.hasTimerRunning ? .Live : .Old
    }

    public func handleAddingEntry() throws {
        switch selectedLiveOrOld {
        case .Old:
            try addEntry()
        case .Live:
            if defaultManager.hasFeedTimerRunning {
                try stopFeedTimer()
            } else {
                startFeedTimer()
            }
        }
    }

    public func addEntry() throws {
        guard startDate != endDate else {
            throw EntryError.sameSleepDate
        }
        guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
        else {
            throw EntryError.invalidSleepDate
        }

        let feed: BreastFeed = .init(id: UUID().uuidString, date: startDate, start: startDate, end: endDate)
        dataManager.addBreastFeed(feed)
        reset()
    }

    public func editEntry() throws {
        guard startDate != endDate else {
            throw EntryError.sameSleepDate
        }

        guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
        else {
            throw EntryError.invalidSleepDate
        }

        guard let index = dataManager.breastFeedData.firstIndex(where: { $0.id == itemID })
        else {
            throw EntryError.general
        }
        let newFeed: BreastFeed = .init(id: itemID, date: startDate, start: startDate, end: endDate)
        dataManager.updateBreastFeed(newFeed, index: index)
        reset()
    }

    public func setInitialValues(with id: String) {
        guard let item = dataManager.breastFeedData.first(where: { $0.id == id }) else {
            return
        }
        itemID = id
        startDate = item.start
        endDate = item.end
    }

    public func reset() {
        startDate = .init()
        endDate = .init()
    }

    // MARK: - Private methods

    private func stopFeedTimer() throws {
        defaultManager.hasTimerRunning = false
        guard let startTime = defaultManager.feedStartDate else {
            throw EntryError.invalidSleepDate
        }
        let feed = BreastFeed(id: UUID().uuidString, date: .now, start: startTime, end: .now)

        dataManager.addBreastFeed(feed)
        reset()
        defaultManager.feedStartDate = nil
        defaultManager.hasFeedTimerRunning = false
        NotificationCenter.default.post(name: NSNotification.feedTimerEnd , object: nil)
    }

    private func startFeedTimer() {
        defaultManager.hasFeedTimerRunning = false
        defaultManager.feedStartDate = nil
        defaultManager.hasFeedTimerRunning = true
        defaultManager.feedStartDate = .now
        NotificationCenter.default.post(name: NSNotification.feedTimerStart , object: nil)
    }
}

// MARK: BreastFeedEntryViewModel.LiveOrOld
public extension BreastFeedEntryViewModel {
    enum LiveOrOld: String, Codable, CaseIterable {
        case Live, Old
    }
}

public extension NSNotification {
    static let feedTimerStart = NSNotification.Name("FeedTimerStart")
    static let feedTimerEnd = NSNotification.Name("FeedTimerEnd")
}
