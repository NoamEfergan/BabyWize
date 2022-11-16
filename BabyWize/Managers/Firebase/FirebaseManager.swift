//
//  FirebaseManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

struct FirebaseManager {
    @InjectedObject private var defaultsManager: UserDefaultManager
    let db = Firestore.firestore()
    let authVM = AuthViewModel()

    init() {
        loginIfPossible()
    }

    func addFeed(_ item: Feed) {
        guard let id = defaultsManager.userID else {
            return
        }
        let feedDTO: [String: Any] = [
            "date": item.date,
            "amount": item.amount,
            "note": item.note ?? "",
            "solidOrLiquid": item.solidOrLiquid.rawValue
        ]
        // Add a new document with a generated ID
        var ref: DocumentReference?
        ref = db
            .collection("users")
            .document(id)
            .collection("feeds")
            .addDocument(data: [item.id: feedDTO]) { err in
                if let err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
    }

    private func loginIfPossible() {
        Task {
            if defaultsManager.hasAccount {
                let credentials = try? KeychainManager.fetchCredentials()
                defaultsManager.userID = await authVM.login(email: credentials?.email ?? "",
                                                            password: credentials?.password ?? "")
            } else {
                defaultsManager.userID = await authVM.anonymousLogin()
            }
        }
    }
}
