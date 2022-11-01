//
//  EntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

final class EntryViewModel: ObservableObject {
    @InjectedObject private var dataManager: BabyDataManager
    @Published var amount = ""
    @Published var feedDate: Date = .init()
    @Published var sleepDate: Date = .init()
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var changeDate: Date = .init()
    @Published var wetOrSoiled: NappyChange.WetOrSoiled = .wet
    @Published var feedNote = ""

    private var itemID = ""

    func addEntry(type: EntryType) throws {
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount) else {
                throw EntryError.invalidAmount
            }
            let note = feedNote.isEmpty ? nil : feedNote
            let feed: Feed = .init(id: UUID().uuidString, date: feedDate, amount: amountDouble, note: note)
            dataManager.addFeed(feed)

        case .sleep:
            guard startDate != endDate else {
                throw EntryError.sameSleepDate
            }
            guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
            else {
                throw EntryError.invalidSleepDate
            }
            let duration = endDate.timeIntervalSince(startDate)
            let sleep: Sleep = .init(id: UUID().uuidString, date: sleepDate, duration: duration.hourMinuteSecondMS)
            dataManager.addSleep(sleep)
        case .nappy:
            let nappyChange: NappyChange = .init(id: UUID().uuidString, dateTime: changeDate, wetOrSoiled: wetOrSoiled)
            dataManager.addNappyChange(nappyChange)
        }
        reset()
    }

    func editEntry(type: EntryType) throws {
        guard !itemID.isEmpty else {
            throw EntryError.general
        }
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount)
            else {
                throw EntryError.invalidAmount
            }

            guard let index = dataManager.feedData.firstIndex(where: { $0.id.description == itemID })
            else {
                throw EntryError.general
            }
            let note = feedNote.isEmpty ? nil : feedNote
            let newFeed: Feed = .init(id: itemID, date: feedDate, amount: amountDouble, note: note)
            dataManager.updateFeed(newFeed, index: index)
        case .sleep:
            guard startDate != endDate else {
                throw EntryError.sameSleepDate
            }

            guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
            else {
                throw EntryError.invalidSleepDate
            }

            guard let index = dataManager.sleepData.firstIndex(where: { $0.id.description == itemID })
            else {
                throw EntryError.general
            }

            let duration = endDate.timeIntervalSince(startDate)
            let newSleep: Sleep = .init(id: itemID, date: sleepDate, duration: duration.hourMinuteSecondMS)
            dataManager.sleepData[index] = newSleep
        case .nappy:
            guard let index = dataManager.nappyData.firstIndex(where: { $0.id.description == itemID })
            else {
                throw EntryError.general
            }
            let newNappy: NappyChange = .init(id: itemID, dateTime: changeDate, wetOrSoiled: wetOrSoiled)
            dataManager.nappyData[index] = newNappy
        }
        reset()
    }

    func setInitialValues(type: EntryType, with id: String) {
        itemID = id
        switch type {
        case .feed:
            guard let item = dataManager.feedData.first(where: { $0.id.description == id }) else {
                return
            }
            amount = item.amount.roundDecimalPoint().description
            feedDate = item.date
            if let note = item.note {
                feedNote = note
            }
        case .sleep:
            // TODO: Find a way to get this
            return

        case .nappy:
            guard let item = dataManager.nappyData.first(where: { $0.id.description == id })
            else {
                return
            }
            changeDate = item.dateTime
            wetOrSoiled = item.wetOrSoiled
        }
    }

    func reset() {
        // Reset all values after setting
        amount = ""
        feedDate = .init()
        startDate = .init()
        endDate = .init()
        changeDate = .init()
        sleepDate = .init()
        wetOrSoiled = .wet
        feedNote = ""
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
