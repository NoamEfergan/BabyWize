//
//  FeedEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import Foundation
import Swinject

final class FeedEntryViewModel: EntryViewModel {
    @InjectedObject private var dataManager: BabyDataManager
    @Published var amount = ""
    @Published var feedDate: Date = .init()
    @Published var feedNote = ""
    @Published var solidOrLiquid: Feed.SolidOrLiquid = .liquid
    var itemID = ""

    init() {}

    func addEntry() throws {
        guard !amount.isEmpty, let amountDouble = Double(amount) else {
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

    func editEntry() throws {
        guard !amount.isEmpty, let amountDouble = Double(amount)
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

    func setInitialValues(with id: String) {
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

    func reset() {
        amount = ""
        feedDate = .init()
        feedNote = ""
        solidOrLiquid = .liquid
        itemID = ""
    }
}
