//
//  FirebaseManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct FirebaseManager {
//    @Inject private var dataManager: BabyDataManager
    let db = Firestore.firestore()
    
    func addFeed(_ item: Feed) {
        guard let email = UserDefaults.standard.string(forKey: UserConstants.email) else { return }
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db
            .collection("users")
            .document(email)
            .collection("feeds")
            .addDocument(data: [item.id:["amount":item.amount, "date":item.date]])
 { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}
