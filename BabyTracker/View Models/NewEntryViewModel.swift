//
//  NewEntryViewModel.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

final class NewEntryViewModel: ObservableObject {
    @Inject private var feedManager: FeedManager
    @Inject private var sleepManager: SleepManager
    @Inject private var nappyManager: NappyManager

    @Published var amount: String = ""
    @Published var feedDate: Date = .init()
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var changeDate: Date = .init()

    func addEntry(type: EntryType) throws {
        switch type {
        case .feed:
            guard !amount.isEmpty, let amountDouble = Double(amount) else { throw EntryError.invalidAmount }
            feedManager.data.append(.init(id: UUID().uuidString, date: feedDate, amount: amountDouble))
        case .sleep:
            guard startDate != endDate else { throw EntryError.sameSleepDate}
            guard startDate.timeIntervalSince1970 > endDate.timeIntervalSince1970 else { throw EntryError.invalidSleepDate}
            let duration = endDate.timeIntervalSince(startDate)
            sleepManager.data.append(.init(id: UUID().uuidString, date: endDate, duration: duration))
        case .nappy:
            nappyManager.data.append(.init(id: UUID().uuidString, dateTime: changeDate))
        }
    }

    enum EntryError: Error {
        case invalidAmount
        case sameSleepDate
        case invalidSleepDate
        
        
        var errorText: String {
            switch self {
            case .invalidAmount:
                return "Please enter a valid amount"
            case .sameSleepDate:
                return "Start and end date can't be the same"
            case.invalidSleepDate:
                return "End date cannot be later than start date"
            }
        }
    }
}
