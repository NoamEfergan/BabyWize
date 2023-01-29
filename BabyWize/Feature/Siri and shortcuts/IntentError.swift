//
//  IntentError.swift
//  BabyWize
//
//  Created by Noam Efergan on 29/01/2023.
//

import Foundation

enum IntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case general
    case message(_ message: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case let .message(message): return "\(message)"
        case .general: return "Something went wrong, please try again later"
        }
    }
}
