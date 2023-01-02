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
    @Published var feedDate: Date = .init()
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var selectedLiveOrOld: LiveOrOld = .Old

    var itemID = ""

    init() {
        selectedLiveOrOld = defaultManager.hasTimerRunning ? .Live : .Old
    }

    func addEntry() throws {
        guard startDate != endDate else {
            throw EntryError.sameSleepDate
        }
        guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
        else {
            throw EntryError.invalidSleepDate
        }

        let feed: BreastFeed = .init(id: UUID().uuidString, date: feedDate, start: startDate, end: endDate)
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
        let newFeed: BreastFeed = .init(id: itemID, date: feedDate, start: startDate, end: endDate)
        dataManager.updateBreastFeed(newFeed, index: index)
        reset()
    }

    func setInitialValues(with id: String) {
        guard let item = dataManager.breastFeedData.first(where: { $0.id == id }) else {
            return
        }
        itemID = id
        feedDate = item.date
        startDate = item.start
        endDate = item.end
    }

    func reset() {
        startDate = .init()
        endDate = .init()
        feedDate = .init()
    }
}

// MARK: BreastFeedEntryViewModel.LiveOrOld
extension BreastFeedEntryViewModel {
    enum LiveOrOld: String, Codable, CaseIterable {
        case Live, Old
    }
}

extension NSNotification {
    static let feedTimerStart = NSNotification.Name("FeedTimerStart")
    static let feedTimerEnd = NSNotification.Name("FeedTimerEnd")
}
