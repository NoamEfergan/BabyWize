//
//  CoreDataExtensions.swift
//  BabyTracker
//
//  Created by Noam Efergan on 08/09/2022.
//
import CoreData
import Foundation

extension SavedFeed {
    func mapToFeed() -> Feed {
        .init(id: id ?? "", date: date ?? Date(), amount: amount)
    }
}

extension SavedSleep {
    func mapToSleep() -> Sleep {
        .init(id: id ?? "", date: date ?? Date(), duration: duration ?? "")
    }
}

extension SavedNappyChange {
    func mapToNappyChange() -> NappyChange {
        .init(id: id ?? "", dateTime: dateTime ?? Date())
    }
}

extension Feed {
    func mapToSavedFeed(context: NSManagedObjectContext) {
        let savedFeed = SavedFeed(context: context)
        savedFeed.id = id
        savedFeed.date = date
        savedFeed.amount = amount
    }
}

extension Sleep {
    func mapToSavedSleep(context: NSManagedObjectContext) {
        let savedSleep = SavedSleep(context: context)
        savedSleep.id = id
        savedSleep.date = date
        savedSleep.duration = duration
    }
}

extension NappyChange {
    func mapToSavedChange(context: NSManagedObjectContext) {
        let savedChange = SavedNappyChange(context: context)
        savedChange.id = id
        savedChange.dateTime = dateTime
    }
}
