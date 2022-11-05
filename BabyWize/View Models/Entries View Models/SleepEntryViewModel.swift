//
//  SleepEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import Foundation
import Swinject

final class SleepEntryViewModel: EntryViewModel {
    @InjectedObject private var dataManager: BabyDataManager
    @Published var sleepDate: Date = .init()
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    var itemID = ""

    init() {}

    func addEntry() throws {
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

        guard let index = dataManager.sleepData.firstIndex(where: { $0.id.description == itemID })
        else {
            throw EntryError.general
        }

        let duration = endDate.timeIntervalSince(startDate)
        let newSleep: Sleep = .init(id: itemID, date: sleepDate, duration: duration.hourMinuteSecondMS)
        dataManager.sleepData[index] = newSleep
        reset()
    }

    func setInitialValues(with id: String) {}

    func reset() {
        startDate = .init()
        endDate = .init()
        sleepDate = .init()
    }
}
