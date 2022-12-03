//
//  IntentManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 02/12/2022.
//

import Foundation
import Intents
import AppIntents

// MARK: - IntentManager
struct IntentManager {
    static func requestSiriAuth() {

    }
}

// MARK: - ShortcutProvider
struct ShortcutProvider: AppShortcutsProvider {
    @AppShortcutsBuilder static var appShortcuts: [AppShortcut] {
            AppShortcut(intent: LogFeed(), phrases: [
                "Log a feed"
            ])
    }
}
