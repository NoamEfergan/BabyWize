//
//  NappyChange.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation

struct NappyChange: Codable, Identifiable {
    var id: String
    let dateTime: Date
}
