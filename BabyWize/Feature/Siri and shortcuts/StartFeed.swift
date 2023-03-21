//
//  StartFeed.swift
//  BabyWize
//
//  Created by Noam Efergan on 29/01/2023.
//

import Foundation
import AppIntents

struct StartFeed: AppIntent {
    @Inject private var defaultManager: UserDefaultManager
    static var title: LocalizedStringResource = "Start a feed timer"
    static var description: IntentDescription? = "Quickly start a breast feeding timer"
    static var suggestedInvocationPhrase = "Start a sleep on baby wize"

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard defaultManager.hasFeedTimerRunning == false else {
            throw IntentError.message("There's already a feed timer running")
        }
        defaultManager.startBreastFeedTimer()
        return .result(dialog: "Timer has started, it's visible in the app")
    }
}

