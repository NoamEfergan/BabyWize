//
//  RealmManager.swift
//  BabyTracker
//
//  Created by Noam Efergan on 21/07/2022.
//

import Foundation
import RealmSwift

final class RealmManager: ObservableObject {
    private let schemaVersion: UInt64 = 1
    private(set) var realm: Realm?

    // MARK: - Init methods

    init() {
        openRealm()
    }

    private func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: schemaVersion)
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
        }
        catch {
            print("failed to open realm \(error.localizedDescription)")
        }
    }

    // MARK: - Public methods

    func add(_ item: Object) {
        guard let realm else { print("Failed to open local realm"); return }

        do {
            try realm.write {
                realm.add(item)
            }
        }
        catch {
            print("Failed to write feed")
        }
    }

    func get<Item: DataItem>(_ type: EntryType) -> [Item]? {
        guard let realm else { print("Failed to open local realm"); return nil }
        switch type {
        case .feed:
            let feeds = realm.objects(Feed.self)
            return Array(feeds) as? [Item]
        case .sleep:
            let sleeps = realm.objects(Sleep.self)
            return Array(sleeps) as? [Item]
        case .nappy:
            let nappyChanges = realm.objects(NappyChange.self)
            return Array(nappyChanges) as? [Item]
        }
    }

    func update(id: ObjectId, type: EntryType, item: some DataItem) {
        guard let realm else { print("Failed to open local realm"); return }
        do {
            switch type {
            case .feed:
                guard let newItem = item as? Feed else {
                    print("Wrong object given for entry type")
                    return
                }
                try realm.write {
                    realm.add(newItem, update: .modified)
                }
            case .sleep:
                guard let newItem = item as? Sleep else {
                    print("Wrong object given for entry type")
                    return
                }
                try realm.write {
                    realm.add(newItem, update: .modified)
                }
            case .nappy:
                guard let newItem = item as? NappyChange else {
                    print("Wrong object given for entry type")
                    return
                }
                try realm.write {
                    realm.add(newItem, update: .modified)
                }
            }
        }

        catch {
            print("Failed to update item \(item)")
        }
    }

    func delete(id: ObjectId, type: EntryType) {
        guard let realm else { print("Failed to open local realm"); return }
        do {
            switch type {
            case .feed:
                guard let item = realm.objects(Feed.self).first(where: { $0.id == id }) else {
                    print("Failed to find object with id: \(id.description)")
                    return
                }
                try realm.write {
                    realm.delete(item)
                }
            case .sleep:
                guard let item = realm.objects(Sleep.self).first(where: { $0.id == id }) else {
                    print("Failed to find object with id: \(id.description)")
                    return
                }
                try realm.write {
                    realm.delete(item)
                }

            case .nappy:
                guard let item = realm.objects(NappyChange.self).first(where: { $0.id == id }) else {
                    print("Failed to find object with id: \(id.description)")
                    return
                }
                try realm.write {
                    realm.delete(item)
                }
            }
        }

        catch {
            print("Failed to delete item \(id.description)")
        }
    }

    // MARK: - Private methods
}
