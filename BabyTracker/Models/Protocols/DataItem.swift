//
//  DataItem.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation

protocol DataItem: Codable, Hashable, Identifiable {
    var id: String { get }
}
