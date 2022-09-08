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
        .init(id: id ?? "" , date: date ?? Date(), amount: amount)
    }
}

extension SavedSleep {
    func mapToSleep() -> Sleep {
        .init(id: id ?? "", date: date ?? Date(), duration: duration ?? "")
    }
}

extension SavedNappyChange {
    func mapToNappyChange() -> NappyChange {
        .init(id: id ?? "" , dateTime: dateTime ?? Date())
    }
}

extension Feed {
    func mapToSavedFeed(context: NSManagedObjectContext) {
        let savedFeed = SavedFeed(context: context)
        savedFeed.id = self.id
        savedFeed.date = self.date
        savedFeed.amount = self.amount
    }
}

extension Sleep {
    func mapToSavedSleep(context: NSManagedObjectContext) {
        let savedSleep = SavedSleep(context: context)
        savedSleep.id = self.id
        savedSleep.date = self.date
        savedSleep.duration = self.duration
    }
}

extension NappyChange {
    func mapToSavedChange(context: NSManagedObjectContext) {
        let savedChange = SavedNappyChange(context: context)
        savedChange.id = self.id
        savedChange.dateTime = self.dateTime
    }
}
