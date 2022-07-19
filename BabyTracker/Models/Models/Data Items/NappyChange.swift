//
//  NappyChange.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

struct NappyChange: DataItem {
    var id =  UUID()
    let specifier: String
    let dateTime: Date
}
