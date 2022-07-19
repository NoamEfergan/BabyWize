//
//  Feed.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

struct Feed: DataItem {
    var id =  UUID()
    let specifier: String
    let date: Date
    let amount: Double
}
