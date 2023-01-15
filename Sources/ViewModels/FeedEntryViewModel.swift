//
//  FeedEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import Foundation
import Swinject
import Models
import Managers

public final class FeedEntryViewModel: EntryViewModel {
    @InjectedObject private var dataManager: BabyDataManager
    @Published public var amount = ""
    @Published public var feedDate: Date = .init()
    @Published public var feedNote = ""
    @Published public var solidOrLiquid: Feed.SolidOrLiquid = .liquid
    public var itemID = ""

    public init() {}

    public func addEntry() throws {
        guard !amount.isEmpty, let amountDouble = Double(amount), !amountDouble.isNaN else {
            throw EntryError.invalidAmount
        }
        let note = feedNote.isEmpty ? nil : feedNote
        let feed: Feed = .init(id: UUID().uuidString,
                               date: feedDate,
                               amount: amountDouble,
                               note: note,
                               solidOrLiquid: solidOrLiquid)
        dataManager.addFeed(feed)
        reset()
    }

    public func editEntry() throws {
        guard !amount.isEmpty, let amountDouble = Double(amount), !amountDouble.isNaN
        else {
            throw EntryError.invalidAmount
        }

        guard let index = dataManager.feedData.firstIndex(where: { $0.id.description == itemID })
        else {
            throw EntryError.general
        }
        let note = feedNote.isEmpty ? nil : feedNote
        let newFeed: Feed = .init(id: itemID,
                                  date: feedDate,
                                  amount: amountDouble,
                                  note: note,
                                  solidOrLiquid: solidOrLiquid)
        dataManager.updateFeed(newFeed, index: index)
        reset()
    }

    public func setInitialValues(with id: String) {
        itemID = id
        guard let item = dataManager.feedData.first(where: { $0.id.description == id }) else {
            return
        }
        amount = item.amount.roundDecimalPoint().description
        feedDate = item.date
        if let note = item.note {
            feedNote = note
        }
    }

    public func reset() {
        amount = ""
        feedDate = .init()
        feedNote = ""
        solidOrLiquid = .liquid
        itemID = ""
    }
}
