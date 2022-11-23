//
//  FirebaseManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import FirebaseCore
import FirebaseFirestore
import Foundation
import Combine

// MARK: - FirebaseManager
final class FirebaseManager {
    @InjectedObject private var defaultsManager: UserDefaultManager
    @InjectedObject private var authVM: AuthViewModel
    private let db = Firestore.firestore()
    private var bag = Set<AnyCancellable>()

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
            await fetchAllFromRemote()
            listenToLogin()
        }
    }

    // MARK: - Public methods

    func fetchAllFromRemote() async {
        await getAllFeeds()
        await getAllSleeps()
        await getAllChanges()
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
    @discardableResult
    func getSharedData(for id: String,email: String? = nil, addID: Bool = true) async -> Bool {
        do {
            let collection = try await db
                .collection(FBKeys.kUsers)
                .getDocuments()

            if let documentRef = collection.documents.first(where: { $0.documentID == id })?.reference {
                let changes = try await documentRef.collection(FBKeys.kChanges).getDocuments()
                let feeds = try await documentRef.collection(FBKeys.kFeeds).getDocuments()
                let sleeps = try await documentRef.collection(FBKeys.kSleeps).getDocuments()

                dataManager?.mergeChangesWithRemote(changes.mapToDomainChange())
                dataManager?.mergeFeedsWithRemote(feeds.mapToDomainFeed())
                dataManager?.mergeSleepsWithRemote(sleeps.mapToDomainSleep())
                if addID {
                    await addIdToShared(id, email: email)
                }
                return true
            } else {
                return false
            }
        }
        catch {
            print("Failed to get shared data with error \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Get/ edit

    private func getAllSleeps() async {
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

    private func getAllChanges() async {
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

    private func getAllFeeds() async {
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

    private func addIdToShared(_ id: String, email: String?) async {
        guard let userID else {
            return
        }
        //TODO: This needs to be an array on firebase
        if let email {
            defaultsManager.sharingAccounts = [.init(id: id, email: email)]
        }
        do {
            try await db
                .collection(FBKeys.kUsers)
                .document(userID)
                .setData([FBKeys.kShared: id], merge: false)
            try await db
                .collection(FBKeys.kUsers)
                .document(id)
                .setData([FBKeys.kShared: userID], merge: false)
        } catch {
            print("Failed to set id to shared with me with error: \(error.localizedDescription)")
        }
    }

    private func fetchSharedDataIfAvailable(id: String) async {
        do {
            let user = try await db.collection(FBKeys.kUsers).document(id).getDocument()
            if let sharedID = user.get(FBKeys.kShared) as? String {
                await getSharedData(for: sharedID, addID: false)
            }
        } catch {
            print("Failed fetching user with error: \(error.localizedDescription)")
        }
    }

    private func loginIfPossible() async {
        if defaultsManager.hasAccount {
            let credentials = try? KeychainManager.fetchCredentials()
            let id = await authVM.login(email: credentials?.email ?? "",
                                        password: credentials?.password ?? "",
                                        shouldSaveToKeychain: false)
            defaultsManager.userID = id
            userID = id
            if let id {
                await fetchSharedDataIfAvailable(id: id)
            }
        } else {
            let id = await authVM.anonymousLogin()
            defaultsManager.userID = id
            userID = id
        }
    }

    private func listenToLogin() {
        authVM
            .$didLogIn
            .receive(on: DispatchQueue.main)
            .sink { didLogIn in
                print("Did log in \(didLogIn)")
                if didLogIn {
                    Task { [weak self] in
                        guard let self else {
                            return
                        }
                        await self.fetchAllFromRemote()
                    }
                }
            }
            .store(in: &bag)
    }
}
