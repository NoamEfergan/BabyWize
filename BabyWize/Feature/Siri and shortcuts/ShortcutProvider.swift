//
//  ShortcutProvider.swift
//  BabyWize
//
//  Created by Noam Efergan on 22/03/2023.
//

import Foundation
import ActivityKit
import AppIntents

// MARK: - ShortcutProvider
struct ShortcutProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .pink
    static var appShortcuts: [AppShortcut] =
        [
            AppShortcut(intent: LogFeed(),
                        phrases: [
                            "Log a feed on \(.applicationName)"
                        ]),
            AppShortcut(intent: LogSleep(),
                        phrases: [
                            "Log a sleep on \(.applicationName)"
                        ]),
            AppShortcut(intent: LogNappy(),
                        phrases: [
                            "Log a nappy change on \(.applicationName)"
                        ]),
            AppShortcut(intent: StartSleep(),
                        phrases: [
                            "Start a sleep timer on \(.applicationName)"
                        ]),
            AppShortcut(intent: StartFeed(),
                        phrases: [
                            "Start a feed timer on \(.applicationName)"
                        ])
        ]
}
