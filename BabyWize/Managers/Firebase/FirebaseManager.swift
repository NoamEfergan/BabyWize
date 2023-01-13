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
import Models

// MARK: - FirebaseManager
class FirebaseManager {
    typealias FirebaseDocument = FirebaseFirestore.DocumentReference
    var defaultsManager: UserDefaultManager
    var authVM: AuthViewModel
    var bag = Set<AnyCancellable>()
    var listenerRegistration: ListenerRegistration?
    let db = Firestore.firestore()

    var dataManager: BabyDataManager?

    init(authVM: AuthViewModel, defaultsManager: UserDefaultManager) {
        self.authVM = authVM
        self.defaultsManager = defaultsManager
    }

    func setup(with dataManager: BabyDataManager) {
        Task { [weak self] in
            guard let self else {
                return
            }
            self.dataManager = dataManager
            await self.loginIfPossible()
            await fetchAllFromRemote()
            listenToLogin()
            addListeners()
        }
    }

    // MARK: - Public methods

    func fetchAllFromRemote() async {
        await getAllFeeds()
        await getAllSleeps()
        await getAllChanges()
    }

    func createUser(with givenId: String) {
        let document: FirebaseDocument = db.collection(FBKeys.kUsers).document(givenId)
        document.setData([FBKeys.kShared: []]) { error in
            if let error {
                print("Failed with error: \(error.localizedDescription)")
            }
        }
    }

    func removeIdFromShared(_ Id: String) {
        guard let userID = defaultsManager.userID else {
            return
        }
        let ref = db
            .collection(FBKeys.kUsers)
            .document(userID)


        db.runTransaction { transaction, error in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(ref)
            } catch {
                print("Failed with error: \(error.localizedDescription)")
                return [:]
            }
            guard var shared: [String: String] = document.data()?[FBKeys.kShared] as? [String: String] else {
                print("Failed to map remote document to array of dictionaries")
                return [:]
            }

            shared.removeValue(forKey: Id)
            transaction.updateData([FBKeys.kShared: shared], forDocument: ref)
            return shared
        } completion: { _, error in
            if let error {
                print("Failed with error: \(error.localizedDescription)")
            }
            else {
                self.defaultsManager.removeSharingAccount(with: Id)
            }
        }
    }

    func fetchSharedDataIfAvailable(id: String, addID: Bool = false) async {
        do {
            let user = try await db.collection(FBKeys.kUsers).document(id).getDocument()
            if let sharingAccounts = user.get(FBKeys.kShared) as? [[String: String]] {
                for sharingAccount in sharingAccounts {
                    guard let email = sharingAccount.values.first,
                          let id = sharingAccount.keys.first else {
                        print("Failed to get email or ID from shared account!")
                        break
                    }
                    await getSharedData(for: id, email: email, addID: addID)
                }
            } else if let sharingAccount = user.get(FBKeys.kShared) as? [String: String] {
                guard let email = sharingAccount.values.first,
                      let id = sharingAccount.keys.first else {
                    print("Failed to get email or ID from shared account!")
                    return
                }
                await getSharedData(for: id, email: email, addID: addID)
            } else {
                print("Failed to map to sharing accounts!")
            }
        } catch {
            print("Failed fetching user with error: \(error.localizedDescription)")
        }
    }

    // MARK: - Add

    func addFeed(_ item: Feed) {
        guard let userID = defaultsManager.userID else {
            print("Failed to add feed to remote, no userID")
            return
        }

        let feedDTO: [String: Any] = [
            FBKeys.kDate: item.date,
            FBKeys.kAmount: item.amount,
            FBKeys.kNote: item.note ?? "",
            FBKeys.kID: item.id,
            FBKeys.kSolidLiquid: item.solidOrLiquid.title.lowercased(),
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
        guard let userID = defaultsManager.userID else {
            print("Failed to add sleep to remote, no userID")
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
        guard let userID = defaultsManager.userID else {
            print("Failed to add nappy change to remote, no userID")
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

    func addBreastFeed(_ item: BreastFeed) {
        guard let userID = defaultsManager.userID else {
            print("Failed to add breast feed to remote, no userID")
            return
        }
        let feedDTO: [String: Any] = [
            FBKeys.kID: item.id,
            FBKeys.kDate: item.date,
            FBKeys.kStart: item.start,
            FBKeys.kEnd: item.end
        ]
        db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(FBKeys.kBreast)
            .document(item.id)
            .setData(feedDTO) { err in
                if let err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
            }
    }

    @discardableResult
    func getSharedData(for id: String,email: String, addID: Bool = true) async -> Bool {
        do {
            let collection = try await db
                .collection(FBKeys.kUsers)
                .getDocuments()

            if let documentRef = collection.documents.first(where: { $0.documentID == id })?.reference {
                let changes = try await documentRef.collection(FBKeys.kChanges).getDocuments()
                let feeds = try await documentRef.collection(FBKeys.kFeeds).getDocuments()
                let sleeps = try await documentRef.collection(FBKeys.kSleeps).getDocuments()

                await dataManager?.mergeChangesWithRemote(changes.mapToDomainChange())
                await dataManager?.mergeFeedsWithRemote(feeds.mapToDomainFeed())
                await dataManager?.mergeSleepsWithRemote(sleeps.mapToDomainSleep())
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
        guard let userID = defaultsManager.userID,
              let remoteFeedSnapshot = try? await db
              .collection(FBKeys.kUsers)
              .document(userID)
              .collection(FBKeys.kSleeps)
              .getDocuments()
        else {
            return
        }
        let sleeps = remoteFeedSnapshot.mapToDomainSleep()
        await dataManager?.mergeSleepsWithRemote(sleeps)
    }

    private func getAllChanges() async {
        guard let userID = defaultsManager.userID,
              let remoteFeedSnapshot = try? await db
              .collection(FBKeys.kUsers)
              .document(userID)
              .collection(FBKeys.kChanges)
              .getDocuments()
        else {
            return
        }
        let changes = remoteFeedSnapshot.mapToDomainChange()
        await dataManager?.mergeChangesWithRemote(changes)
    }

    private func getAllFeeds() async {
        guard let userID = defaultsManager.userID,
              let remoteFeedSnapshot = try? await db
              .collection(FBKeys.kUsers)
              .document(userID)
              .collection(FBKeys.kFeeds)
              .getDocuments()
        else {
            return
        }
        let feeds = remoteFeedSnapshot.mapToDomainFeed()
        await dataManager?.mergeFeedsWithRemote(feeds)
    }

    // MARK: - Delete

    func removeItems(items: [any DataItem], key: String) {
        guard let userID = defaultsManager.userID else {
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

    private func addIdToShared(_ id: String, email: String) async {
        guard let userID = defaultsManager.userID, let userEmail = defaultsManager.email else {
            return
        }
        defaultsManager.addNewSharingAccount(.init(id: id, email: email))
        let sharingAccountDTO: [String: String] = [
            id: email
        ]

        let sharingToAccountDTO: [String: String] = [
            userID:userEmail
        ]

        do {
            try await db
                .collection(FBKeys.kUsers)
                .document(userID)
                .setData([FBKeys.kShared: sharingAccountDTO], merge: true)
            try await db
                .collection(FBKeys.kUsers)
                .document(id)
                .setData([FBKeys.kShared: sharingToAccountDTO], merge: true)
        } catch {
            print("Failed to set id to shared with me with error: \(error.localizedDescription)")
        }
    }

    private func loginIfPossible() async {
        if defaultsManager.hasAccount,
           let credentials = try? KeychainManager.fetchCredentials(),
           let id = await authVM.login(email: credentials.email,
                                       password: credentials.password,
                                       shouldSaveToKeychain: false) {
            defaultsManager.signIn(with: id, email: credentials.email)
            await fetchSharedDataIfAvailable(id: id)
        } else {
            let id = await authVM.anonymousLogin()
            defaultsManager.userID = id
        }
    }

    func deleteAccount(userID: String) {
        db.collection(FBKeys.kUsers).document(userID).delete { error in
            if let error {
                print("Failed to delete account with error: \(error.localizedDescription)")
            } else {
                print("account deleted")
            }
        }
    }
}
