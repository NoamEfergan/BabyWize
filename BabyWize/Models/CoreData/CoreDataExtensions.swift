//
//  CoreDataExtensions.swift
//  BabyWize
//
//  Created by Noam Efergan on 08/09/2022.
//
import CoreData
import Foundation

extension SavedFeed {
    func mapToFeed() -> Feed {
        let solidOrLiquid = Feed.SolidOrLiquid(rawValue: solidOrLiquid ?? "") ?? .liquid
        return .init(id: id ?? "",
                     date: date ?? Date(),
                     amount: amount,
                     note: note,
                     solidOrLiquid: solidOrLiquid)
    }
}

extension SavedSleep {
    func mapToSleep() -> Sleep {
        .init(id: id ?? "", date: date ?? Date(), start: start ?? Date(), end: end ?? Date())
    }
}

extension SavedNappyChange {
    func mapToNappyChange() -> NappyChange {
        .init(id: id ?? "", dateTime: dateTime ?? Date(), wetOrSoiled: .init(rawValue: wetOrSoiled ?? "") ?? .wet)
    }
}

extension Feed {
    func mapToSavedFeed(context: NSManagedObjectContext) {
        let savedFeed = SavedFeed(context: context)
        savedFeed.id = id
        savedFeed.date = date
        savedFeed.amount = amount
        savedFeed.note = note
        savedFeed.solidOrLiquid = solidOrLiquid.rawValue
    }
}

extension Sleep {
    func mapToSavedSleep(context: NSManagedObjectContext) {
        let savedSleep = SavedSleep(context: context)
        savedSleep.id = id
        savedSleep.date = date
        savedSleep.start = start
        savedSleep.end = end
    }
}

extension NappyChange {
    func mapToSavedChange(context: NSManagedObjectContext) {
        let savedChange = SavedNappyChange(context: context)
        savedChange.id = id
        savedChange.dateTime = dateTime
        savedChange.wetOrSoiled = wetOrSoiled.rawValue
    }
}
