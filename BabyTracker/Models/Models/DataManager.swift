//
//  DataManager.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

protocol DataManager: ObservableObject {
    associatedtype BabyData
    var data: BabyData { get set }
    func fetchData() async -> BabyData
}
