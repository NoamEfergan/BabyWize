//
//  Array+Extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation

extension Array {
    func getUpTo(limit: Int) -> Self {
        count < limit ? self : suffix(limit)
    }
}
