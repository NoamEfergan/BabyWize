//
//  EntryViewModel.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

final class EntryViewModel: ObservableObject {
    @Inject private var dataManager: BabyDataManager

    @Published var amount: String = ""
    @Published var feedDate: Date = .init()
    @Published var sleepDate: Date = .init()
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var changeDate: Date = .init()

    func addEntry(type: EntryType) throws {
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount) else { throw EntryError.invalidAmount }
            dataManager.feedData.append(.init(specifier: UUID().uuidString, date: feedDate, amount: amountDouble))
        case .sleep:
            guard startDate != endDate else { throw EntryError.sameSleepDate }
            guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
            else { throw EntryError.invalidSleepDate }
            let duration = endDate.timeIntervalSince(startDate)
            dataManager.sleepData.append(
                .init(specifier: UUID().uuidString,
                      date: sleepDate,
                      duration: duration.hourMinuteSecondMS)
            )
        case .nappy:
            dataManager.nappyData.append(.init(specifier: UUID().uuidString, dateTime: changeDate))
        }
        reset()
    }

    func editEntry(type: EntryType, with id: String) throws {
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount)
            else { throw EntryError.invalidAmount }

            guard let index = dataManager.feedData.firstIndex(where: { $0.specifier == id })
            else { throw EntryError.general }

            dataManager.feedData[index] = .init(specifier: id, date: feedDate, amount: amountDouble)
        case .sleep:
            guard startDate != endDate else { throw EntryError.sameSleepDate }

            guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
            else { throw EntryError.invalidSleepDate }

            guard let index = dataManager.sleepData.firstIndex(where: { $0.specifier == id })
            else { throw EntryError.general }

            let duration = endDate.timeIntervalSince(startDate)
            dataManager.sleepData[index] = .init(specifier: id, date: sleepDate, duration: duration.hourMinuteSecondMS)
        case .nappy:
            guard let index = dataManager.nappyData.firstIndex(where: { $0.specifier == id })
            else { throw EntryError.general }

            dataManager.nappyData[index] = .init(specifier: id, dateTime: changeDate)
        }
    }

    func setInitialValues(type: EntryType, with id: String) {
        switch type {
        case .feed:
            guard let item = dataManager.feedData.first(where: { $0.specifier == id }) else { return }
            amount = item.amount.roundDecimalPoint().description
            feedDate = item.date
        case .sleep:
            // TODO: Find a way to get this
            return

        case .nappy:
            guard let item = dataManager.nappyData.first(where: { $0.specifier == id })
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
