//
//  DataController.swift
//  BabyWize
//
//  Created by Noam Efergan on 06/09/2022.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "UserEntriesModel")

    init() {
        container.loadPersistentStores { _, error in
            if let error {
                print("Failed with error: \(error.localizedDescription)")
                return
            }
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}
