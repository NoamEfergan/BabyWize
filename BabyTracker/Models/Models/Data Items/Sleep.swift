//
//  Sleep.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

struct Sleep: DataItem {
    var id =  UUID()
    let specifier: String
    let date: Date
    let duration: String
}
