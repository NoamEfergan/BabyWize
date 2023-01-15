//
//  LogNappy.swift
//  BabyWize
//
//  Created by Noam Efergan on 03/12/2022.
//
import Foundation
import AppIntents
@preconcurrency import Models

// MARK: - LogNappy
struct LogNappy: AppIntent {
    @Inject private var dataManager: BabyDataManager
    static var title: LocalizedStringResource = "Log a nappy change"
    static var description: IntentDescription? = "Quickly and hands free log a nappy change into you Baby Wize database"
    static var suggestedInvocationPhrase = "Log a nappy change on baby wize"

    @Parameter(title: "Wet or soiled?",
               requestValueDialog: "Was it a wet nappy or a soiled nappy?")
    var wetOrSoiled: IntentWetOrSoiled?

    static var parameterSummary: some ParameterSummary {
        Summary("Log a \(\.$wetOrSoiled) nappy change")
    }

    func perform() async throws -> some IntentResult {
        guard let wetOrSoiled else {
            throw $wetOrSoiled.needsValueError("Was the nappy wet or soiled?")
        }
        let newNappyChange = NappyChange(id: UUID().uuidString,
                                         dateTime: .now,
                                         wetOrSoiled: .init(rawValue: wetOrSoiled.rawValue) ?? .wet)
        await dataManager.addNappyChange(newNappyChange)
        return .result(dialog: "Done! logged a \(wetOrSoiled.rawValue) nappy change")
    }
}

// MARK: - IntentWetOrSoiled
enum IntentWetOrSoiled: String, AppEnum {
    static var typeDisplayRepresentation = TypeDisplayRepresentation("WetOrSoiled")

    static var caseDisplayRepresentations: [IntentWetOrSoiled : DisplayRepresentation] =
        [
            .wet : .init(stringLiteral: "Wet"),
            .soiled : .init(stringLiteral: "Soiled")
        ]

    case wet = "Wet"
    case soiled = "Soiled"
}

// MARK: - WetOrSoiledProvider
struct WetOrSoiledProvider: DynamicOptionsProvider {
    func results() async throws -> [IntentWetOrSoiled] {
        [IntentWetOrSoiled.soiled, IntentWetOrSoiled.wet]
    }
}
