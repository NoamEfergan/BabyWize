//
//  LogSleep.swift
//  BabyWize
//
//  Created by Noam Efergan on 03/12/2022.
//

import Foundation
import AppIntents
@preconcurrency import Models
import Managers

public struct LogSleep: AppIntent {
    @Inject var dataManager: BabyDataManager
    public static var title: LocalizedStringResource = "Log a sleep"
    public static var description: IntentDescription? =
        "Quickly and hands free log a sleep into your Baby Wize database"
    public static var suggestedInvocationPhrase = "Log a sleep on baby wize"

    public init() {}

    @Parameter(title: "From", requestValueDialog: "From when")
    var start: Date?

    @Parameter(title: "Until", requestValueDialog: "Until when")
    var end: Date?

    public static var parameterSummary: some ParameterSummary {
        Summary("Add a sleep to your Baby Wize sleep entries")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let start else {
            throw $start.needsValueError("When did they go to sleep?")
        }
        guard let end else {
            throw $end.needsValueError("When did they wake up?")
        }

        let newSleep = Sleep(id: UUID().uuidString,
                             date: .now,
                             start: start,
                             end: end)

        await dataManager.addSleep(newSleep)
        return .result(dialog: "Added a sleep to your diary!")
    }
}
