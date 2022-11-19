//
//  FirebaseManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

// MARK: - FirebaseManager
final class FirebaseManager {
    @InjectedObject private var defaultsManager: UserDefaultManager
    private let db = Firestore.firestore()
    private let authVM = AuthViewModel()
    private var userID: String?
    private var dataManager: BabyDataManager?

    init() {}

    func setup(with dataManager: BabyDataManager) {
        Task { [weak self] in
            guard let self else {
                return
            }
            userID = defaultsManager.userID
            self.dataManager = dataManager
            await self.loginIfPossible()
            await getAllFeeds()
            await getAllSleeps()
            await getAllChanges()
        }
    }

    // MARK: - Add

    func addFeed(_ item: Feed) {
        guard let userID else {
            return
        }
        let feedDTO: [String: Any] = [
            FBKeys.kDate: item.date,
            FBKeys.kAmount: item.amount,
            FBKeys.kNote: item.note ?? "",
            FBKeys.kID: item.id,
            FBKeys.kSolidLiquid: item.solidOrLiquid.rawValue
        ]
        db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(FBKeys.kFeeds)
            .document(item.id)
            .setData(feedDTO) { err in
                if let err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
    }

    func addSleep(_ item: Sleep) {
        guard let userID else {
            return
        }
        let sleepDTO: [String: Any] = [
            FBKeys.kID: item.id,
            FBKeys.kDate: item.date,
            FBKeys.kStart: item.start,
            FBKeys.kEnd: item.end
        ]
        db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(FBKeys.kSleeps)
            .document(item.id)
            .setData(sleepDTO) { err in
                if let err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
    }

    func addNappyChange(_ item: NappyChange) {
        guard let userID else {
            return
        }
        let changeDTO: [String: Any] = [
            FBKeys.kID: item.id,
            FBKeys.kDate: item.dateTime,
            FBKeys.kWetOrSoiled: item.wetOrSoiled.rawValue,
        ]
        db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(FBKeys.kChanges)
            .document(item.id)
            .setData(changeDTO) { err in
                if let err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
    }

    // MARK: - Get/ edit

    func getAllSleeps() async {
        guard let userID,
              let remoteFeedSnapshot = try? await db
              .collection(FBKeys.kUsers)
              .document(userID)
              .collection(FBKeys.kSleeps)
              .getDocuments()
        else {
            return
        }
        let sleeps = remoteFeedSnapshot.mapToDomainSleep()
        dataManager?.mergeSleepsWithRemote(sleeps)
    }

    func getAllChanges() async {
        guard let userID,
              let remoteFeedSnapshot = try? await db
              .collection(FBKeys.kUsers)
              .document(userID)
              .collection(FBKeys.kChanges)
              .getDocuments()
        else {
            return
        }
        let changes = remoteFeedSnapshot.mapToDomainChange()
        dataManager?.mergeChangesWithRemote(changes)
    }

    func getAllFeeds() async {
        guard let userID,
              let remoteFeedSnapshot = try? await db
              .collection(FBKeys.kUsers)
              .document(userID)
              .collection(FBKeys.kFeeds)
              .getDocuments()
        else {
            return
        }
        let feeds = remoteFeedSnapshot.mapToDomainFeed()
        dataManager?.mergeFeedsWithRemote(feeds)
    }

    // MARK: - Delete

    func removeItems(items: [any DataItem], key: String) {
        guard let userID else {
            return
        }
        let batch = db.batch()
        for item in items {
            let ref = db.collection(FBKeys.kUsers).document(userID).collection(key).document(item.id)
            batch.deleteDocument(ref)
        }
        batch.commit { error in
            if let error {
                print("Failed to delete item with: \(error)")
            } else {
                print("Remove successfully ")
            }
        }
    }

    // MARK: - Private methods

    private func loginIfPossible() async {
        if defaultsManager.hasAccount {
            let credentials = try? KeychainManager.fetchCredentials()
            let id = await authVM.login(email: credentials?.email ?? "",
                                        password: credentials?.password ?? "")
            defaultsManager.userID = id
            userID = id
        } else {
            let id = await authVM.anonymousLogin()
            defaultsManager.userID = id
            userID = id
        }
    }
}

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

