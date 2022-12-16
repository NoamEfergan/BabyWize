//
//  FirebaseListeners.swift
//  BabyWize
//
//  Created by Noam Efergan on 16/12/2022.
//

import FirebaseCore
import FirebaseFirestoreCombineSwift
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
                        self.addListeners()
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
        listenerRegistration = db
            .collection(userID)
            .document(FBKeys.kFeeds)
            .addSnapshotListener { _, _ in
                print("Noam: Here ✋")
            }

        db
            .collection(userID)
            .document(FBKeys.kFeeds)
            .snapshotPublisher()
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { snapshot in
                print(snapshot)
            }.store(in: &bag)
    }
}
