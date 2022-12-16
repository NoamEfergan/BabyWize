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
    }

    func addListeners() {
        guard let userID = defaultsManager.userID else {
            return
        }
        addFeedsListener(userID: userID)
    }

    private func addFeedsListener(userID: String) {
        db
            .collection(FBKeys.kUsers)
            .document(userID)
            .collection(FBKeys.kFeeds)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    print("Failed with error: \(error.localizedDescription)")
                }
                snapshot?.documentChanges.forEach(self.handleFeedDocumentChange)
            }
    }

    private func handleFeedDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            if let feed = change.document.mapToFeed() {
                dataManager?.addFeed(feed, updateRemote: false)
            }
        case .modified:
            if let feed = change.document.mapToFeed(),
               let index = dataManager?.feedData.firstIndex(where: { $0.id == feed.id }) {
                dataManager?.updateFeed(feed, index: index, updateRemote: false)
            }
        case .removed:
            print(change.document.data())
            if let feed = change.document.mapToFeed(),
               let indices = dataManager?.feedData.filter({ $0.id == feed.id }).indices.compactMap({ Int($0) }) {
                let indexSet = IndexSet(indices)
                dataManager?.removeFeed(at: indexSet)
            }
        }
    }
}
