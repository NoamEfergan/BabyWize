//
//  StartSleep.swift
//  BabyWize
//
//  Created by Noam Efergan on 22/01/2023.
//

import Foundation
import AppIntents

struct StartSleep: AppIntent {
    @Inject private var defaultManager: UserDefaultManager
    static var title: LocalizedStringResource = "Start a sleep timer"
    static var description: IntentDescription? = "Quickly start a sleep timer"
    static var suggestedInvocationPhrase = "Start a sleep on baby wize"

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard defaultManager.hasTimerRunning == false else {
            throw IntentError.message("There's already a sleep timer running")
        }
        defaultManager.startSleepTimer()
        return .result(dialog: "Timer has started, it's visible in the app")
    }
}
