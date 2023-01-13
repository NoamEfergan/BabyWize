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
import Models

final class BabyDataManager: ObservableObject {
    // MARK: - Private variables

    @Inject private var firebaseManager: FirebaseManager
    @InjectedObject private var unitsManager: UserDefaultManager

    // MARK: - Exposed variables

    @Published var sleepData: [Sleep] = [] {
        didSet {
            lastSleepString = getLast(for: .sleep)
        }
    }

    @Published var feedData: [Feed] = [] {
        didSet {
            lastFeedString = getLastFeed()
        }
    }

    @Published var breastFeedData: [BreastFeed] = [] {
        didSet {
            lastFeedString = getLastFeed()
        }
    }

    @Published var nappyData: [NappyChange] = [] {
        didSet {
            lastChangeString = getLast(for: .nappy)
        }
    }

    @Published var lastFeedString: String = .nonAvailable
    @Published var lastSleepString: String = .nonAvailable
    @Published var lastChangeString: String = .nonAvailable

    private var bag = Set<AnyCancellable>()

    init() {
        listenToUnitChanges()
        firebaseManager.setup(with: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logOutAndRemoveAll),
                                               name: .didLogOut,
                                               object: .none)
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
        case .breastFeed:
            return breastFeedData.isEmpty
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
            return .nonAvailable
        case .breastFeed:
            return getAverageBreastFeed()
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
            return .nonAvailable
        case .breastFeed:
            return breastFeedData.max(by: { $0.getDuration() < $1.getDuration() })?.getDuration() ?? .nonAvailable
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
            return .nonAvailable
        case .breastFeed:
            return breastFeedData.min(by: { $0.getDuration() < $1.getDuration() })?.getDuration() ?? .nonAvailable
        }
    }

    func mergeFeedsWithRemote(_ remoteFeeds: [Feed]) {
        defer {
            feedData = feedData.uniqued(on: { $0.id })
        }
        if feedData.isEmpty {
            remoteFeeds.forEach { addFeed($0) }
        }
        else {
            for (remoteFeed, localFeed) in product(remoteFeeds, feedData) {
                if !feedData.contains(where: { $0.id == remoteFeed.id }) {
                    addFeed(remoteFeed)
                }
                else if localFeed.id == remoteFeed.id {
                    if localFeed != remoteFeed,
                       let index = feedData.firstIndex(where: { $0.id == localFeed.id }) {
                        updateFeed(remoteFeed, index: index, updateRemote: false)
                    }
                }
            }
        }
    }

    func mergeSleepsWithRemote(_ remoteSleeps: [Sleep]) {
        defer {
            sleepData = sleepData.uniqued(on: { $0.id })
        }
        if sleepData.isEmpty {
            remoteSleeps.forEach { addSleep($0) }
        }
        else {
            for (remoteSleep, localSleep) in product(remoteSleeps, sleepData) {
                if !sleepData.contains(where: { $0.id == remoteSleep.id }) {
                    addSleep(remoteSleep)
                }
                else if localSleep.id == remoteSleep.id {
                    if localSleep != remoteSleep,
                       let index = sleepData.firstIndex(where: { $0.id == localSleep.id }) {
                        updateSleep(remoteSleep, index: index, updateRemote: false)
                    }
                }
            }
        }
    }

    func mergeChangesWithRemote(_ remoteChanges: [NappyChange]) {
        defer {
            nappyData = nappyData.uniqued(on: { $0.id })
        }
        if nappyData.isEmpty {
            remoteChanges.forEach { addNappyChange($0) }
        }
        else {
            for (remoteChange, localChange) in product(remoteChanges, nappyData) {
                if !nappyData.contains(where: { $0.id == remoteChange.id }) {
                    addNappyChange(remoteChange)
                }
                else if localChange.id == remoteChange.id {
                    if localChange != remoteChange,
                       let index = nappyData.firstIndex(where: { $0.id == localChange.id }) {
                        updateChange(remoteChange, index: index, updateRemote: false)
                    }
                }
            }
        }
    }

    // MARK: - CRUD methods

    // ADD
    func addFeed(_ item: Feed, updateRemote: Bool = true) {
        feedData.append(item)
        feedData = feedData.uniqued(on: { $0.id })
        if updateRemote {
            firebaseManager.addFeed(item)
        }
    }

    func addSleep(_ item: Sleep, updateRemote: Bool = true) {
        sleepData.append(item)
        sleepData = sleepData.uniqued(on: { $0.id })
        if updateRemote {
            firebaseManager.addSleep(item)
        }
    }

    func addNappyChange(_ item: NappyChange, updateRemote: Bool = true) {
        nappyData.append(item)
        nappyData = nappyData.uniqued(on: { $0.id })
        if updateRemote {
            firebaseManager.addNappyChange(item)
        }
    }

    func addBreastFeed(_ item: BreastFeed, updateRemote: Bool = true) {
        breastFeedData.append(item)
        breastFeedData = breastFeedData.uniqued(on: { $0.id })
        if updateRemote {
            firebaseManager.addBreastFeed(item)
        }
    }

    // Update

    func updateFeed(_ item: Feed, index: Array<Feed>.Index, updateRemote: Bool = true) {
        if updateRemote {
            firebaseManager.addFeed(item)
        } else {
            feedData[index] = item
        }
    }

    func updateSleep(_ item: Sleep, index: Array<Sleep>.Index, updateRemote: Bool = true) {
        sleepData[index] = item
        if updateRemote {
            firebaseManager.addSleep(item)
        }
    }

    func updateChange(_ item: NappyChange, index: Array<NappyChange>.Index, updateRemote: Bool = true) {
        nappyData[index] = item
        if updateRemote {
            firebaseManager.addNappyChange(item)
        }
    }

    func updateBreastFeed(_ item: BreastFeed, index: Array<Sleep>.Index, updateRemote: Bool = true) {
        breastFeedData[index] = item
        if updateRemote {
            firebaseManager.addBreastFeed(item)
        }
    }

    // Remove

    func removeFeed(item: Feed, includingRemote: Bool = true) {
        guard let index = feedData.firstIndex(where: { $0.id == item.id }) else {
            print("Failed to find feed to remvoe")
            return
        }
        let feed = feedData[index]
        feedData.removeAll(where: { $0 == feed })
        if includingRemote {
            firebaseManager.removeItems(items: [feed], key: FBKeys.kFeeds)
        }
    }

    func removeFeed(at offsets: IndexSet, includingRemote: Bool = true) {
        let localFeeds = offsets.compactMap {
            feedData[$0]
        }.uniqued(on: { $0.id })
        feedData.remove(atOffsets: offsets)
        if includingRemote {
            firebaseManager.removeItems(items: localFeeds, key: FBKeys.kFeeds)
        }
    }

    func removeSleep(at offsets: IndexSet, includingRemote: Bool = true) {
        let localSleeps = offsets.compactMap {
            sleepData[$0]
        }.uniqued(on: { $0.id })
        sleepData.remove(atOffsets: offsets)
        if includingRemote {
            firebaseManager.removeItems(items: localSleeps, key: FBKeys.kSleeps)
        }
    }

    func removeChange(at offsets: IndexSet, includingRemote: Bool = true) {
        let localChanges = offsets.compactMap {
            nappyData[$0]
        }.uniqued(on: { $0.id })
        nappyData.remove(atOffsets: offsets)
        if includingRemote {
            firebaseManager.removeItems(items: localChanges, key: FBKeys.kChanges)
        }
    }

    func removeBreastFeed(at offsets: IndexSet, includingRemote: Bool = true) {
        let localFeeds = offsets.compactMap {
            breastFeedData[$0]
        }.uniqued(on: { $0.id })
        breastFeedData.remove(atOffsets: offsets)
        if includingRemote {
            firebaseManager.removeItems(items: localFeeds, key: FBKeys.kBreast)
        }
    }

    func removeAll(for entry: EntryType, includingRemote: Bool = true) {
        switch entry {
        case .liquidFeed:
            let indices = feedData.filter(\.isLiquids).indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeFeed(at: indexSet, includingRemote: includingRemote)

        case .sleep:
            let indices = sleepData.indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeSleep(at: indexSet, includingRemote: includingRemote)

        case .nappy:
            let indices = nappyData.indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeChange(at: indexSet, includingRemote: includingRemote)

        case .solidFeed:
            let indices = feedData.filter(\.isSolids).indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeFeed(at: indexSet, includingRemote: includingRemote)
        case .breastFeed:
            let indices = breastFeedData.indices.compactMap { Int($0) }
            let indexSet = IndexSet(indices)
            removeSleep(at: indexSet, includingRemote: includingRemote)
        }
    }

    // MARK: - Private methods

    private func getLastFeed() -> String {
        guard let lastBreastFeed = breastFeedData.last else {
            return getLast(for: .liquidFeed)
        }
        guard let lastFeed = feedData.last else {
            return getLast(for:.breastFeed)
        }

        if lastBreastFeed.date < lastFeed.date {
            return getLast(for: .liquidFeed)
        } else {
            return getLast(for: .breastFeed)
        }
    }

    private func getLast(for type: EntryType) -> String {
        defer {
            _ = self.objectWillChange
        }
        switch type {
        case .liquidFeed, .solidFeed:
            let sortedFeeds = feedData.sorted(by: { $0.date < $1.date })
            guard let lastItem = sortedFeeds.last else {
                return .nonAvailable
            }
            return lastItem.amount.displayableAmount(isSolid: lastItem.isSolids)
        case .sleep:
            let sortedSleeps = sleepData.sorted(by: { $0.date < $1.date })
            return sortedSleeps.last?.getDisplayableString() ?? .nonAvailable
        case .nappy:
            let sortedChanges = nappyData.sorted(by: { $0.dateTime < $1.dateTime })
            guard let lastNappy = sortedChanges.last else {
                return .nonAvailable
            }
            return "\(lastNappy.dateTime.formatted(date: .omitted, time: .shortened)), \(lastNappy.wetOrSoiled.rawValue)"
        case .breastFeed:
            let sortedFeeds = breastFeedData.sorted(by: { $0.date < $1.date })
            return sortedFeeds.last?.getDisplayableString() ?? .nonAvailable
        }
    }

    @objc private func logOutAndRemoveAll() {
        EntryType.allCases.forEach { removeAll(for: $0, includingRemote: false) }
    }

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

    private func getAverageBreastFeed() -> String {
        let totalAmount = breastFeedData.reduce(0) {
            $0 + $1.getTimeInterval()
        }
        let amount = (totalAmount / Double(breastFeedData.count))
        if amount.isNaN {
            return .nonAvailable
        }
        return amount.hourMinuteSecondMS
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
            .sink(receiveValue: { [weak self] pair in
                guard let self else {
                    print("Failed to capture self")
                    return
                }
                guard let from = pair.0,
                      let to = pair.1
                else {
                    return
                }
                self.feedData.filter(\.isLiquids).forEach { feed in
                    guard let index = self.feedData.firstIndex(where: { $0.id == feed.id }) else {
                        print("Failed to convert liquid feed unit, no feed found")
                        return
                    }
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
