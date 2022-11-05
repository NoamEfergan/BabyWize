//
//  EntryViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

// MARK: - EntryViewModel
protocol EntryViewModel: ObservableObject {
    func addEntry() throws
    func editEntry() throws
    func setInitialValues(with id: String)
    func reset()
    var itemID: String { get set }
}

// MARK: - EntryError
enum EntryError: Error {
    case invalidAmount
    case sameSleepDate
    case invalidSleepDate
    case general

    var errorText: String {
        switch self {
        case .invalidAmount:
            return "Please enter a valid amount"
        case .sameSleepDate:
            return "Start and end date can't be the same"
        case .invalidSleepDate:
            return "End date cannot be sooner than start date"
        case .general:
            return "Whoops! something went wrong, sorry about that."
        }
    }
}
