//
//  LogSleep.swift
//  BabyWize
//
//  Created by Noam Efergan on 03/12/2022.
//

import Foundation
import AppIntents
import Models

struct LogSleep: AppIntent {
    @Inject private var dataManager: BabyDataManager
    static var title: LocalizedStringResource = "Log a sleep"
    static var description: IntentDescription? = "Quickly and hands free log a sleep into your Baby Wize database"
    static var suggestedInvocationPhrase = "Log a sleep on baby wize"

    @Parameter(title: "From", requestValueDialog: "From when")
    var start: Date?

    @Parameter(title: "Until", requestValueDialog: "Until when")
    var end: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Add a sleep to your Baby Wize sleep entries")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
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
