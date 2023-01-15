//
//  AddEntryViewVM.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/12/2022.
//

import Foundation
import SwiftUI
import Combine
import Models
import Managers

final class AddEntryViewVM: ObservableObject {
    @Inject private var defaultManager: UserDefaultManager
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var errorText = ""
    @Published var entryType: EntryType = .liquidFeed

    @Published var feedVM: FeedEntryViewModel = .init()
    @Published var sleepVM: SleepEntryViewModel = .init()
    @Published var nappyVM: NappyEntryViewModel = .init()
    @Published var breastFeedVM: BreastFeedEntryViewModel = .init()
    @Published var shouldDismiss = false
    @Published var buttonTitle = ""
    private var bag = Set<AnyCancellable>()

    init() {
        listenToLiveOrOld()
        buttonTitle = getButtonTitle()
    }

    func getButtonTitle() -> String {
        let add = "Add"
        let stop = "Stop"
        let start = "Start"

        switch entryType {
        case .sleep:
            if sleepVM.selectedLiveOrOld == .Live {
                return defaultManager.hasTimerRunning ? stop : start
            } else {
                return add
            }
        case .breastFeed:
            if breastFeedVM.selectedLiveOrOld == .Live {
                return defaultManager.hasFeedTimerRunning ? stop : start
            } else {
                return add
            }
        default:
            return add
        }
    }

    func handleButtonTap() {
        do {
            switch entryType {
            case .liquidFeed, .solidFeed:
                try feedVM.addEntry()
            case .sleep:
                try sleepVM.handleAddingEntry()
            case .nappy:
                try nappyVM.addEntry()
            case .breastFeed:
                try breastFeedVM.handleAddingEntry()
            }
            shouldDismiss = true
        } catch {
            guard let entryError = error as? EntryError else {
                errorText = "Whoops! something went wrong!"
                return
            }
            errorText = entryError.errorText
        }
    }

    func listenToLiveOrOld() {
        sleepVM
            .$selectedLiveOrOld
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.buttonTitle = self.getButtonTitle()
            }
            .store(in: &bag)

        breastFeedVM
            .$selectedLiveOrOld
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.buttonTitle = self.getButtonTitle()
            }
            .store(in: &bag)
    }
}
