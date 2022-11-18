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
        }
    }

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
        // Add a new document with a generated ID
        var ref: DocumentReference?
        ref = db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(FBKeys.kFeeds)
            .addDocument(data: [item.id: feedDTO]) { err in
                if let err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
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
        guard let data = data().values.first as? [String: Any],
              let amount = data[FBKeys.kAmount] as? Double,
              let note = data[FBKeys.kNote] as? String,
              let solidOrLiquid = data[FBKeys.kSolidLiquid] as? String,
              let timeStamp = data[FBKeys.kDate] as? Timestamp,
              let id = data[FBKeys.kID] as? String
        else {
            return nil
        }
        return .init(id: id,
                     date: Date(timeIntervalSince1970: Double(timeStamp.seconds)),
                     amount: amount,
                     note: note.isEmpty ? nil : note,
                     solidOrLiquid: .init(rawValue: solidOrLiquid) ?? .liquid)
    }
}

extension QuerySnapshot {
    func mapToDomainFeed() -> [Feed] {
        documents.compactMap { $0.mapToFeed() }
    }
}

