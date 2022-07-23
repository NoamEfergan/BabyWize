//
//  DataItem.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import RealmSwift
import SwiftUI

protocol DataItem: Codable, Hashable, Identifiable {
    var id: ObjectId { get }
}

final class NappyChange: Object, ObjectKeyIdentifiable, DataItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var dateTime: Date

    convenience init(id: String, dateTime: Date) {
        self.init()
        self.dateTime = dateTime
    }
}

final class Sleep: Object, ObjectKeyIdentifiable, DataItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date
    @Persisted var duration: String

    convenience init(id: String, date: Date, duration: String) {
        self.init()
        self.date = date
        self.duration = duration
    }
}

final class Feed: Object, ObjectKeyIdentifiable, DataItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date
    @Persisted var amount: Double

    convenience init(id: String, date: Date, amount: Double) {
        self.init()
        self.date = date
        self.amount = amount
    }
}
