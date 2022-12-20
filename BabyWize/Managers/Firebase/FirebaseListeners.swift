//
//  FirebaseListeners.swift
//  BabyWize
//
//  Created by Noam Efergan on 16/12/2022.
//


import FirebaseFirestoreCombineSwift
import FirebaseFirestore
import Foundation
import Combine

extension FirebaseManager {
    func listenToLogin() {
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
                        if let userID = self.defaultsManager.userID {
                            await self.fetchAllFromRemote()
                            await self.fetchSharedDataIfAvailable(id: userID, addID: true)
                        }
                    }
                }
            }
            .store(in: &bag)

        authVM
            .$didRegister
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                if let id {
                    print("Did register \(id)")
                    self?.createUser(with: id)
                }
            }
            .store(in: &bag)

        authVM
            .$didDeleteAccount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userID in
                if let userID {
                    self?.deleteAccount(userID: userID)
                }
            }
            .store(in: &bag)
    }

    func addListeners() {
        guard let userID = defaultsManager.userID else {
            return
        }
        // Filtering out one of the feeds as it doesn't matter which one, and this will ensure no double listeners are
        // added
        EntryType
            .allCases
            .filter { $0 != .solidFeed }
            .forEach { self.addEntryListenerListener(userID: userID, for: $0) }
    }

    private func addEntryListenerListener(userID: String, for entryType: EntryType) {
        var collectionName: String {
            switch entryType {
            case .liquidFeed, .solidFeed:
                return FBKeys.kFeeds
            case .sleep:
                return FBKeys.kSleeps
            case .nappy:
                return FBKeys.kChanges
            }
        }
        db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(collectionName)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    print("Failed with error: \(error.localizedDescription)")
                }
                switch entryType {
                case .liquidFeed, .solidFeed:
                    snapshot?.documentChanges.forEach(self.handleFeedDocumentChange)
                case .sleep:
                    snapshot?.documentChanges.forEach(self.handleSleepDocumentChange)
                case .nappy:
                    snapshot?.documentChanges.forEach(self.handleNappyDocumentChange)
                }
            }
    }

    private func handleFeedDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            if let feed = change.document.mapToFeed() {
                dataManager?.addFeed(feed, updateRemote: false)
            } else {
                print("Failed to add feed from remote notification")
            }
        case .modified:
            if let feed = change.document.mapToFeed(),
               let index = dataManager?.feedData.firstIndex(where: { $0.id == feed.id }) {
                dataManager?.updateFeed(feed, index: index, updateRemote: false)
            } else {
                print("Failed to modify feed from remote notification")
            }
        case .removed:
            print("Feed removed in remote")
        }
    }

    private func handleSleepDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            if let sleep = change.document.mapToSleep() {
                dataManager?.addSleep(sleep, updateRemote: false)
            } else {
                print("Failed to add sleep from remote notification")
            }
        case .modified:
            if let sleep = change.document.mapToSleep(),
               let index = dataManager?.sleepData.firstIndex(where: { $0.id == sleep.id }) {
                dataManager?.updateSleep(sleep, index: index, updateRemote: false)
            } else {
                print("Failed to modify sleep from remote notification")
            }
        case .removed:
            print("Sleep removed in remote")
        }
    }


    private func handleNappyDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            if let nappyChange = change.document.mapToChange() {
                dataManager?.addNappyChange(nappyChange, updateRemote: false)
            } else {
                print("Failed to add nappy change from remote notification")
            }
        case .modified:
            if let nappyChange = change.document.mapToChange(),
               let index = dataManager?.nappyData.firstIndex(where: { $0.id == nappyChange.id }) {
                dataManager?.updateChange(nappyChange, index: index, updateRemote: false)
            } else {
                print("Failed to modify nappy change from remote notification")
            }
        case .removed:
            print("Nappy change removed in remote")
        }
    }
}
