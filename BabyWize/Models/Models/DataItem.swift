//
//  DataItem.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import SwiftUI

protocol DataItem: Codable, Hashable, Identifiable {
    var id: String { get }
}

struct NappyChange: DataItem {
    let id: String
    let dateTime: Date
}

struct Sleep: DataItem {
    let id: String
    let date: Date
    let duration: String
}

struct Feed: DataItem {
    let id: String
    let date: Date
    let amount: Double
}
