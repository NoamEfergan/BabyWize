//
//  FirebaseDataExtensions.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase extensions

extension QueryDocumentSnapshot {
    func mapToFeed() -> Feed? {
        let mappedData = data()
        guard let amount = mappedData[FBKeys.kAmount] as? Double,
              let note = mappedData[FBKeys.kNote] as? String,
              let solidOrLiquid = mappedData[FBKeys.kSolidLiquid] as? String,
              let timeStamp = mappedData[FBKeys.kDate] as? Timestamp,
              let id = mappedData[FBKeys.kID] as? String
        else {
            return nil
        }
        return .init(id: id,
                     date: Date(timeIntervalSince1970: Double(timeStamp.seconds)),
                     amount: amount,
                     note: note.isEmpty ? nil : note,
                     solidOrLiquid: .init(rawValue: solidOrLiquid) ?? .liquid)
    }

    func mapToSleep() -> Sleep? {
        let mappedData = data()
        guard let id = mappedData[FBKeys.kID] as? String,
              let timeStamp = mappedData[FBKeys.kDate] as? Timestamp,
              let start = mappedData[FBKeys.kStart] as? Timestamp,
              let end = mappedData[FBKeys.kEnd] as? Timestamp
        else {
            return nil
        }
        return .init(id: id,
                     date: .init(timeIntervalSince1970: Double(timeStamp.seconds)),
                     start: .init(timeIntervalSince1970: Double(start.seconds)),
                     end: .init(timeIntervalSince1970: Double(end.seconds)))
    }

    func mapToChange() -> NappyChange? {
        let mappedData = data()
        guard let id = mappedData[FBKeys.kID] as? String,
              let timeStamp = mappedData[FBKeys.kDate] as? Timestamp,
              let wetOrSoiledKey = mappedData[FBKeys.kWetOrSoiled] as? String,
              let wetOrSoiled = NappyChange.WetOrSoiled(rawValue: wetOrSoiledKey) else {
            return nil
        }
        return .init(id: id,
                     dateTime: .init(timeIntervalSince1970: Double(timeStamp.seconds)),
                     wetOrSoiled: wetOrSoiled)
    }
}

extension QuerySnapshot {
    func mapToDomainFeed() -> [Feed] {
        documents.compactMap { $0.mapToFeed() }
    }

    func mapToDomainSleep() -> [Sleep] {
        documents.compactMap { $0.mapToSleep() }
    }

    func mapToDomainChange() -> [NappyChange] {
        documents.compactMap { $0.mapToChange() }
    }
}
