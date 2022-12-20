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
        do {
            try moc.save()
        } catch {
            print("Failed to add feed with error: \(error.localizedDescription)")
        }
    }

    func addSleep(_ item: Sleep) {
        item.mapToSavedSleep(context: moc)
        do {
            try moc.save()
        } catch {
            print("Failed to add sleep with error: \(error.localizedDescription)")
        }
    }

    func addNappyChange(_ item: NappyChange) {
        item.mapToSavedChange(context: moc)
        do {
            try moc.save()
        } catch {
            print("Failed to add nappy change with error: \(error.localizedDescription)")
        }
    }

    // Update

    func updateFeed(_ item: Feed) {
        do {
            let savedFeeds = try moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed]
            let relevantFeed = savedFeeds?.first(where: { $0.id == item.id })
            relevantFeed?.date = item.date
            relevantFeed?.amount = item.amount
            relevantFeed?.note = item.note
            try moc.save()
        } catch {
            print("Failed to update feed with error: \(error.localizedDescription)")
        }
    }

    func updateSleep(_ item: Sleep) {
        do {
            let savedSleeps = try moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]
            let relevantSleep = savedSleeps?.first(where: { $0.id == item.id })
            relevantSleep?.date = item.date
            relevantSleep?.start = item.start
            relevantSleep?.end = item.end

            try moc.save()
        } catch {
            print("Failed to update sleep with error: \(error.localizedDescription)")
        }
    }

    func updateChange(_ item: NappyChange) {
        do {
            let savedChanges = try moc.fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]
            let relevantChange = savedChanges?.first(where: { $0.id == item.id })
            relevantChange?.dateTime = item.dateTime
            relevantChange?.wetOrSoiled = item.wetOrSoiled.rawValue
            try moc.save()
        } catch {
            print("Failed to update nappy change with error: \(error.localizedDescription)")
        }
    }

    // Remove

    func removeFeed(_ localFeeds: [Feed]) {
        do {
            let savedFeeds = try moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed]
            var itemsToDelete: [SavedFeed] = []
            for (local, saved) in product(localFeeds, savedFeeds ?? []) {
                if saved.id == local.id {
                    itemsToDelete.append(saved)
                }
            }
            itemsToDelete.forEach { moc.delete($0) }
            try moc.save()
        } catch {
            print("Failed to delete feed with error: \(error.localizedDescription)")
        }
    }

    func removeSleep(_ localSleeps: [Sleep]) {
        do {
            let savedSleeps = try moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]

            var itemsToDelete: [SavedSleep] = []
            for (local, saved) in product(localSleeps, savedSleeps ?? []) {
                if saved.id == local.id {
                    itemsToDelete.append(saved)
                }
            }
            itemsToDelete.forEach { moc.delete($0) }
            try moc.save()
        } catch {
            print("Failed to remove sleep with error: \(error.localizedDescription)")
        }
    }

    func removeChange(_ localChanges: [NappyChange]) {
        do {
            let savedChanged = try moc.fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]

            var itemsToDelete: [SavedNappyChange] = []
            for (local, saved) in product(localChanges, savedChanged ?? []) {
                if saved.id == local.id {
                    itemsToDelete.append(saved)
                }
            }
            itemsToDelete.forEach { moc.delete($0) }
            try moc.save()
        } catch {
            print("Failed to remove nappy change with error: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper methods

    func fetchFeeds() -> [Feed] {
        do {
            guard let savedFeeds = try moc.fetch(.init(entityName: Constants.savedFeed.rawValue)) as? [SavedFeed] else {
                return []
            }
            return savedFeeds.compactMap { $0.mapToFeed() }.uniqued(on: { $0.id })
        } catch {
            print("Failed fetch feeds with error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchSleeps() -> [Sleep] {
        do {
            guard let savedSleeps = try moc.fetch(.init(entityName: Constants.savedSleep.rawValue)) as? [SavedSleep]
            else {
                return []
            }
            return savedSleeps.compactMap { $0.mapToSleep() }.uniqued(on: { $0.id })
        } catch {
            print("Failed fetch sleeps with error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchChanges() -> [NappyChange] {
        do {
            guard let savedChanges = try moc
                .fetch(.init(entityName: Constants.savedChange.rawValue)) as? [SavedNappyChange]
            else {
                return []
            }
            return savedChanges.compactMap { $0.mapToNappyChange() }.uniqued(on: { $0.id })
        } catch {
            print("Failed fetch nappy changes with error: \(error.localizedDescription)")
            return []
        }
    }
}
