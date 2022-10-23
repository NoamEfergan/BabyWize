//
//  BabyCoreDataManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import Algorithms
import Foundation

struct BabyCoreDataManager {
    private var moc = DataController().container.viewContext

    // MARK: - CRUD methods

    // ADD

    func addFeed(_ item: Feed) {
        item.mapToSavedFeed(context: moc)
        try? moc.save()
    }

    func addSleep(_ item: Sleep) {
        item.mapToSavedSleep(context: moc)
        try? moc.save()
    }

    func addNappyChange(_ item: NappyChange) {
        item.mapToSavedChange(context: moc)
        try? moc.save()
    }

    // Update

    func updateFeed(_ item: Feed) {
        let savedFeeds = try? moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed]
        let relevantFeed = savedFeeds?.first(where: { $0.id == item.id })
        relevantFeed?.date = item.date
        relevantFeed?.amount = item.amount
        try? moc.save()
    }

    func updateSleep(_ item: Sleep) {
        let savedSleeps = try? moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]
        let relevantSleep = savedSleeps?.first(where: { $0.id == item.id })
        relevantSleep?.date = item.date
        relevantSleep?.duration = item.duration
        try? moc.save()
    }

    func updateChange(_ item: NappyChange) {
        let savedChanges = try? moc.fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]
        let relevantChange = savedChanges?.first(where: { $0.id == item.id })
        relevantChange?.dateTime = item.dateTime
        try? moc.save()
    }

    // Remove

    func removeFeed(_ localFeeds: [Feed]) {
        let savedFeeds = try? moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed]

        var itemsToDelete: [SavedFeed] = []
        for (local, saved) in product(localFeeds, savedFeeds ?? []) {
            if saved.id == local.id {
                itemsToDelete.append(saved)
            }
        }
        itemsToDelete.forEach { moc.delete($0) }
        try? moc.save()
    }

    func removeSleep(_ localSleeps: [Sleep]) {
        let savedSleeps = try? moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]

        var itemsToDelete: [SavedSleep] = []
        for (local, saved) in product(localSleeps, savedSleeps ?? []) {
            if saved.id == local.id {
                itemsToDelete.append(saved)
            }
        }
        itemsToDelete.forEach { moc.delete($0) }
        try? moc.save()
    }

    func removeChange(_ localChanges: [NappyChange]) {
        let savedChanged = try? moc.fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]

        var itemsToDelete: [SavedNappyChange] = []
        for (local, saved) in product(localChanges, savedChanged ?? []) {
            if saved.id == local.id {
                itemsToDelete.append(saved)
            }
        }
        itemsToDelete.forEach { moc.delete($0) }
        try? moc.save()
    }

    // MARK: - Helper methods

    func fetchFeeds() -> [Feed] {
        guard let savedFeeds = try? moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed] else {
            return []
        }
        return savedFeeds.compactMap { $0.mapToFeed() }
    }

    func fetchSleeps() -> [Sleep] {
        guard let savedSleeps = try? moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep] else {
            return []
        }
        return savedSleeps.compactMap { $0.mapToSleep() }
    }

    func fetchChanges() -> [NappyChange] {
        guard let savedChanges = try? moc
            .fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]
        else {
            return []
        }
        return savedChanges.compactMap { $0.mapToNappyChange() }
    }
}
