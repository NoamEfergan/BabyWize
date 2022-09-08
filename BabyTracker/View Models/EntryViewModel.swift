//
//  EntryViewModel.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

final class EntryViewModel: ObservableObject {
    @InjectedObject private var dataManager: BabyDataManager
    @Published var amount: String = ""
    @Published var feedDate: Date = .init()
    @Published var sleepDate: Date = .init()
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var changeDate: Date = .init()

    private var itemID: String = ""

    func addEntry(type: EntryType) throws {
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount) else { throw EntryError.invalidAmount }
            let feed: Feed = .init(id: UUID().uuidString, date: feedDate, amount: amountDouble)
            dataManager.addFeed(feed)

        case .sleep:
            guard startDate != endDate else { throw EntryError.sameSleepDate }
            guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
            else { throw EntryError.invalidSleepDate }
            let duration = endDate.timeIntervalSince(startDate)
            let sleep: Sleep = .init(id: UUID().uuidString, date: sleepDate, duration: duration.hourMinuteSecondMS)
            dataManager.addSleep(sleep)
        case .nappy:
            let nappyChange: NappyChange = .init(id: UUID().uuidString, dateTime: changeDate)
            dataManager.addNappyChange(nappyChange)
        }
        reset()
    }

    func editEntry(type: EntryType) throws {
        guard !itemID.isEmpty else { throw EntryError.general }
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount)
            else { throw EntryError.invalidAmount }

            guard let index = dataManager.feedData.firstIndex(where: { $0.id.description == itemID })
            else { throw EntryError.general }
            let newFeed: Feed = .init(id: itemID, date: feedDate, amount: amountDouble)
            dataManager.feedData[index] = newFeed
//            realm.update(id: newFeed.id, type: .feed, item: newFeed)
        case .sleep:
            guard startDate != endDate else { throw EntryError.sameSleepDate }

            guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
            else { throw EntryError.invalidSleepDate }

            guard let index = dataManager.sleepData.firstIndex(where: { $0.id.description == itemID })
            else { throw EntryError.general }

            let duration = endDate.timeIntervalSince(startDate)
            let newSleep: Sleep = .init(id: itemID, date: sleepDate, duration: duration.hourMinuteSecondMS)
            dataManager.sleepData[index] = newSleep
//            realm.update(id: newSleep.id, type: .sleep, item: newSleep)
        case .nappy:
            guard let index = dataManager.nappyData.firstIndex(where: { $0.id.description == itemID })
            else { throw EntryError.general }
            let newNappy: NappyChange = .init(id: itemID, dateTime: changeDate)
            dataManager.nappyData[index] = newNappy
//            realm.update(id: newNappy.id, type: .nappy, item: newNappy)
        }
        reset()
    }

    func setInitialValues(type: EntryType, with id: String) {
        itemID = id
        switch type {
        case .feed:
            guard let item = dataManager.feedData.first(where: { $0.id.description == id }) else { return }
            amount = item.amount.roundDecimalPoint().description
            feedDate = item.date
        case .sleep:
            // TODO: Find a way to get this
            return

        case .nappy:
            guard let item = dataManager.nappyData.first(where: { $0.id.description == id })
            else { return }
            changeDate = item.dateTime
        }
    }

    private func reset() {
        // Reset all values after setting
        amount = ""
        feedDate = .init()
        startDate = .init()
        endDate = .init()
        changeDate = .init()
        sleepDate = .init()
    }

    enum EntryError: Error {
        case invalidAmount
        case sameSleepDate
        case invalidSleepDate
        case general

        var errorText: String {
            switch self {
            case .invalidAmount:
                return "Please enter a valid amount"
            case .sameSleepDate:
                return "Start and end date can't be the same"
            case .invalidSleepDate:
                return "End date cannot be sooner than start date"
            case .general:
                return "Whoops! something went wrong, sorry about that."
            }
        }
    }
}
