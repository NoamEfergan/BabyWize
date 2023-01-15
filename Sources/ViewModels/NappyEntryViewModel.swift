//
//  NappyEntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import Foundation
import Swinject
import Models
import Managers

public final class NappyEntryViewModel: EntryViewModel {
    @InjectedObject private var dataManager: BabyDataManager
    @Published public var changeDate: Date = .init()
    @Published public var wetOrSoiled: NappyChange.WetOrSoiled = .wet
    public var itemID = ""

    public init() {}

    public func addEntry() throws {
        let nappyChange: NappyChange = .init(id: UUID().uuidString, dateTime: changeDate, wetOrSoiled: wetOrSoiled)
        dataManager.addNappyChange(nappyChange)
        reset()
    }

    public func editEntry() throws {
        guard let index = dataManager.nappyData.firstIndex(where: { $0.id == itemID })
        else {
            throw EntryError.general
        }
        let newNappy: NappyChange = .init(id: itemID, dateTime: changeDate, wetOrSoiled: wetOrSoiled)
        dataManager.updateChange(newNappy, index: index)
        reset()
    }

    public func setInitialValues(with id: String) {
        guard let item = dataManager.nappyData.first(where: { $0.id == id })
        else {
            return
        }
        itemID = id
        changeDate = item.dateTime
        wetOrSoiled = item.wetOrSoiled
    }

    public func reset() {
        changeDate = .init()
        wetOrSoiled = .wet
    }
}
