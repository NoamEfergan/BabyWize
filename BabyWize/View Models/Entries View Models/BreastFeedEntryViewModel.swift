//
//  BreastFeedEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 02/01/2023.
//

import Foundation

// MARK: - BreastFeedEntryViewModel
final class BreastFeedEntryViewModel: EntryViewModel {
    @InjectedObject private var dataManager: BabyDataManager
    @Inject private var defaultManager: UserDefaultManager
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var selectedLiveOrOld: LiveOrOld = .Old

    var itemID = ""

    init() {
        selectedLiveOrOld = defaultManager.hasTimerRunning ? .Live : .Old
    }

    func handleAddingEntry() throws {
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

    func addEntry() throws {
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

    func editEntry() throws {
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

    func setInitialValues(with id: String) {
        guard let item = dataManager.breastFeedData.first(where: { $0.id == id }) else {
            return
        }
        itemID = id
        startDate = item.start
        endDate = item.end
    }

    func reset() {
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

    func startFeedTimer() {
        defaultManager.startBreastFeedTimer()
    }
}

// MARK: BreastFeedEntryViewModel.LiveOrOld
extension BreastFeedEntryViewModel {
    enum LiveOrOld: String, Codable, CaseIterable {
        case Live, Old
    }
}
