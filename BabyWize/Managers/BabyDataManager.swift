//
//  BabyDataManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import CoreData
import SwiftUI
import Combine
import Algorithms

final class BabyDataManager: ObservableObject {
    // MARK: - Private variables

    private let coreDataManager = BabyCoreDataManager()
    private let firebaseManager = FirebaseManager()
    @InjectedObject var unitsManager: UserDefaultManager

    // MARK: - Exposed variables

    @Published var sleepData: [Sleep] = []
    @Published var feedData: [Feed] = []
    @Published var nappyData: [NappyChange] = []
    private var bag = Set<AnyCancellable>()

    init() {
        fetchSavedValues()
        listenToUnitChanges()
        firebaseManager.setup(with: self)
    }

    // MARK: - Public methods

    func getIsEmpty(for type: EntryType) -> Bool {
        switch type {
        case .liquidFeed:
            return feedData.filter(\.isLiquids).isEmpty
        case .sleep:
            return sleepData.isEmpty
        case .nappy:
            return nappyData.isEmpty
        case .solidFeed:
            return feedData.filter(\.isSolids).isEmpty
        }
    }

    func getLast(for type: EntryType) -> String {
        defer {
            _ = self.objectWillChange
        }
        switch type {
        case .liquidFeed, .solidFeed:
            guard let lastItem = feedData.last else {
                return .nonAvailable
            }
            return lastItem.amount.displayableAmount(isSolid: lastItem.isSolids)
        case .sleep:
            return sleepData.last?.getDisplayableString() ?? .nonAvailable
        case .nappy:
            guard let lastNappy = nappyData.last else {
                return .nonAvailable
            }
            return "\(lastNappy.dateTime.formatted(date: .omitted, time: .shortened)), \(lastNappy.wetOrSoiled.rawValue) "
        }
    }

    func getAverage(for type: EntryType) -> String {
        switch type {
        case .liquidFeed:
            return getAverageFeed(isSolid: false)
        case .solidFeed:
            return getAverageFeed(isSolid: true)
        case .sleep:
            return getAverageSleepDuration()
        case .nappy:
            // TODO: Make this
            return "Something"
        }
    }

    func getBiggest(for type: EntryType) -> String {
        switch type {
        case .liquidFeed:
            if let max = feedData
                .filter(\.isLiquids)
                .max(by: { $0.amount < $1.amount })?
                .amount,
                !max.isNaN {
                return max.liquidFeedDisplayableAmount()
            } else {
                return .nonAvailable
            }

        case .solidFeed:
            if let max = feedData
                .filter(\.isSolids)
                .max(by: { $0.amount < $1.amount })?
                .amount, !max.isNaN {
                return max.solidFeedDisplayableAmount()
            } else {
                return .nonAvailable
            }
        case .sleep:
            return sleepData.max(by: { $0.getDuration() < $1.getDuration() })?.getDuration() ?? .nonAvailable
        case .nappy:
            return ""
        }
    }

    func getSmallest(for type: EntryType) -> String {
        switch type {
        case .liquidFeed:
            if let min = feedData
                .filter(\.isLiquids)
                .min(by: { $0.amount < $1.amount })?
                .amount, !min.isNaN {
                return min.liquidFeedDisplayableAmount()
            } else {
                return .nonAvailable
            }

        case .solidFeed:
            if let min = feedData
                .filter(\.isSolids)
                .min(by: { $0.amount < $1.amount })?
                .amount, !min.isNaN {
                return min.solidFeedDisplayableAmount()
            } else {
                return .nonAvailable
            }
        case .sleep:
            return sleepData.min(by: { $0.getDuration() < $1.getDuration() })?.getDuration() ?? .nonAvailable
        case .nappy:
            return ""
        }
    }

    func mergeFeedsWithRemote(_ remoteFeeds: [Feed]) {
        for (remoteFeed, localFeed) in product(remoteFeeds, feedData) {
            if localFeed.id == remoteFeed.id {
                if localFeed != remoteFeed,
                   let index = feedData.firstIndex(where: { $0.id == localFeed.id }) {
                    updateFeed(remoteFeed, index: index, updateRemote: false)
                }
            }
        }
    }

    func mergeSleepsWithRemote(_ remoteSleeps: [Sleep]) {
        for (remoteSleep, localSleep) in product(remoteSleeps, sleepData) {
            if localSleep.id == remoteSleep.id {
                if localSleep != remoteSleep,
                   let index = sleepData.firstIndex(where: { $0.id == localSleep.id }) {
                    updateSleep(remoteSleep, index: index, updateRemote: false)
                }
            }
        }
    }
    
    func mergeChangesWithRemote(_ remoteChanges: [NappyChange]) {
        for (remoteChange, localChange) in product(remoteChanges, nappyData) {
            if localChange.id == remoteChange.id {
                if localChange != remoteChange,
                   let index = nappyData.firstIndex(where: { $0.id == localChange.id }) {
                    updateChange(remoteChange, index: index, updateRemote: false)
                }
            }
        }
        
    }

    // MARK: - CRUD methods

    // ADD
    func addFeed(_ item: Feed) {
        feedData.append(item)
        coreDataManager.addFeed(item)
        firebaseManager.addFeed(item)
    }

    func addSleep(_ item: Sleep) {
        sleepData.append(item)
        coreDataManager.addSleep(item)
        firebaseManager.addSleep(item)
    }

    func addNappyChange(_ item: NappyChange) {
        nappyData.append(item)
        coreDataManager.addNappyChange(item)
        firebaseManager.addNappyChange(item)
    }

    // Update

    func updateFeed(_ item: Feed, index: Array<Feed>.Index, updateRemote: Bool = true) {
        feedData[index] = item
        coreDataManager.updateFeed(item)
        if updateRemote {
            firebaseManager.addFeed(item)
        }
    }

    func updateSleep(_ item: Sleep, index: Array<Sleep>.Index, updateRemote: Bool = true) {
        sleepData[index] = item
        coreDataManager.updateSleep(item)
        if updateRemote {
            firebaseManager.addSleep(item)
        }
    }

    func updateChange(_ item: NappyChange, index: Array<NappyChange>.Index, updateRemote: Bool = true) {
        nappyData[index] = item
        coreDataManager.updateChange(item)
        if updateRemote {
            firebaseManager.addNappyChange(item)
        }
    }

    // Remove

    func removeFeed(at offsets: IndexSet) {
        let localFeeds = offsets.compactMap {
            feedData[$0]
        }
        coreDataManager.removeFeed(localFeeds)
        feedData.remove(atOffsets: offsets)
        firebaseManager.removeItems(items: localFeeds, key: FBKeys.kFeeds)
    }

    func removeSleep(at offsets: IndexSet) {
        let localSleeps = offsets.compactMap {
            sleepData[$0]
        }
        coreDataManager.removeSleep(localSleeps)
        sleepData.remove(atOffsets: offsets)
        firebaseManager.removeItems(items: localSleeps, key: FBKeys.kSleeps)
    }

    func removeChange(at offsets: IndexSet) {
        let localChanges = offsets.compactMap {
            nappyData[$0]
        }
        coreDataManager.removeChange(localChanges)
        nappyData.remove(atOffsets: offsets)
        firebaseManager.removeItems(items: localChanges, key: FBKeys.kChanges)
    }

    func removeAll(for entry: EntryType) {
        switch entry {
        case .liquidFeed:
            let indices = feedData.filter(\.isLiquids).indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeFeed(at: indexSet)

        case .sleep:
            let indices = sleepData.indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeSleep(at: indexSet)

        case .nappy:
            let indices = nappyData.indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeChange(at: indexSet)

        case .solidFeed:
            let indices = feedData.filter(\.isSolids).indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeFeed(at: indexSet)
        }
    }

    // MARK: - Private methods

    private func getAverageFeed(isSolid: Bool) -> String {
        let data = isSolid ? feedData.filter(\.isSolids) : feedData.filter(\.isLiquids)
        let totalAmount = data.reduce(0) {
            $0 + $1.amount
        }
        let returnableAmount = (totalAmount / Double(data.count))
        if returnableAmount.isNaN {
            return .nonAvailable
        }
        return returnableAmount.displayableAmount(isSolid: isSolid)
    }

    private func getAverageSleepDuration() -> String {
        let totalAmount = sleepData.reduce(0) {
            $0 + $1.getTimeInterval()
        }
        let amount = (totalAmount / Double(sleepData.count))
        if amount.isNaN {
            return .nonAvailable
        }
        return amount.hourMinuteSecondMS
    }

    private func fetchSavedValues() {
        feedData = coreDataManager.fetchFeeds()
        sleepData = coreDataManager.fetchSleeps()
        nappyData = coreDataManager.fetchChanges()
    }

    private func listenToUnitChanges() {
        unitsManager
            .$liquidUnits
            .scan((nil, nil) as (LiquidFeedUnits?,
                                 LiquidFeedUnits?)) { output, selectedUnit -> (LiquidFeedUnits?, LiquidFeedUnits?) in
                if let to = output.1 {
                    return (to, selectedUnit)
                }

                return (nil, selectedUnit)
            }
            .sink(receiveValue: { pair in
                guard let from = pair.0,
                      let to = pair.1
                else {
                    return
                }
                self.feedData.filter(\.isLiquids).indices.forEach { index in
                    let feed = self.feedData[index]
                    let newFeed = Feed(id: feed.id,
                                       date: feed.date,
                                       amount: feed.amount.convertLiquids(from: from, to: to),
                                       note: feed.note,
                                       solidOrLiquid: feed.solidOrLiquid)
                    self.updateFeed(newFeed, index: index)
                }
            })
            .store(in: &bag)
        
        
        unitsManager
            .$solidUnits
            .scan((nil, nil) as (SolidFeedUnits?,
                                 SolidFeedUnits?)) { output, selectedUnit -> (SolidFeedUnits?, SolidFeedUnits?) in
                if let to = output.1 {
                    return (to, selectedUnit)
                }

                return (nil, selectedUnit)
            }
            .sink(receiveValue: { pair in
                guard let from = pair.0,
                      let to = pair.1
                else {
                    return
                }
                self.feedData.filter(\.isSolids).indices.forEach { index in
                    let feed = self.feedData[index]
                    let newFeed = Feed(id: feed.id,
                                       date: feed.date,
                                       amount: feed.amount.convertSolids(from: from, to: to),
                                       note: feed.note,
                                       solidOrLiquid: feed.solidOrLiquid)
                    self.updateFeed(newFeed, index: index)
                }
            })
            .store(in: &bag)
    }
}
