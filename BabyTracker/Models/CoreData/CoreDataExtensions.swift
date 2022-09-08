//
//  CoreDataExtensions.swift
//  BabyTracker
//
//  Created by Noam Efergan on 08/09/2022.
//

import Foundation

extension SavedFeed {
    func mapToFeed() -> Feed {
        .init(id: self.id ?? "" , date: self.date ?? Date(), amount: self.amount)
    }
}

extension SavedSleep {
    func mapToSleep() -> Sleep {
        .init(id: self.id ?? "", date: self.date ?? Date(), duration: self.duration ?? "")
    }
    
}

extension SavedNappyChange {
    func mapToNappyChange() -> NappyChange {
        .init(id: self.id ?? "" , dateTime: self.dateTime ?? Date())
    }
}
