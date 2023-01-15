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

public final class AddEntryViewVM: ObservableObject {
    @Inject private var defaultManager: UserDefaultManager
    @Published public var startDate: Date = .init()
    @Published public var endDate: Date = .init()
    @Published public var errorText = ""
    @Published public var entryType: EntryType = .liquidFeed

    @Published public var feedVM: FeedEntryViewModel = .init()
    @Published public var sleepVM: SleepEntryViewModel = .init()
    @Published public var nappyVM: NappyEntryViewModel = .init()
    @Published public var breastFeedVM: BreastFeedEntryViewModel = .init()
    @Published public var shouldDismiss = false
    @Published public var buttonTitle = ""
    private var bag = Set<AnyCancellable>()

    public init() {
        listenToLiveOrOld()
        buttonTitle = getButtonTitle()
    }

    public func getButtonTitle() -> String {
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

    public func handleButtonTap() {
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

    private func listenToLiveOrOld() {
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
