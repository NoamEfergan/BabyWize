//
//  SleepEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import Foundation
import Swinject
import Models

// MARK: - SleepEntryViewModel
final class SleepEntryViewModel: EntryViewModel {
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
            if defaultManager.hasTimerRunning {
                try stopSleepTimer()
            } else {
                startSleepTimer()
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

        let sleep: Sleep = .init(id: UUID().uuidString, date: startDate, start: startDate, end: endDate)
        dataManager.addSleep(sleep)
        reset()
    }

    func startSleepTimer() {
        defaultManager.hasTimerRunning = false
        defaultManager.sleepStartDate = nil
        defaultManager.hasTimerRunning = true
        defaultManager.sleepStartDate = .now
        NotificationCenter.default.post(name: NSNotification.sleepTimerStart , object: nil)
    }

    func stopSleepTimer() throws {
        defaultManager.hasTimerRunning = false
        guard let startTime = defaultManager.sleepStartDate else {
            throw EntryError.invalidSleepDate
        }
        let sleep = Sleep(id: UUID().uuidString, date: .now, start: startTime, end: .now)
        dataManager.addSleep(sleep)
        reset()
        defaultManager.sleepStartDate = nil
        NotificationCenter.default.post(name: NSNotification.sleepTimerEnd , object: nil)
    }

    func editEntry() throws {
        guard startDate != endDate else {
            throw EntryError.sameSleepDate
        }

        guard startDate.timeIntervalSince1970 < endDate.timeIntervalSince1970
        else {
            throw EntryError.invalidSleepDate
        }

        guard let index = dataManager.sleepData.firstIndex(where: { $0.id == itemID })
        else {
            throw EntryError.general
        }
        let newSleep: Sleep = .init(id: itemID, date: startDate, start: startDate, end: endDate)
        dataManager.updateSleep(newSleep, index: index)
        reset()
    }

    func setInitialValues(with id: String) {
        guard let item = dataManager.sleepData.first(where: { $0.id == id }) else {
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
}

// MARK: SleepEntryViewModel.LiveOrOld
extension SleepEntryViewModel {
    enum LiveOrOld: String, Codable, CaseIterable {
        case Live, Old
    }
}

extension NSNotification {
    static let sleepTimerStart = NSNotification.Name("SleepTimerStart")
    static let sleepTimerEnd = NSNotification.Name("SleepTimerEnd")
}
