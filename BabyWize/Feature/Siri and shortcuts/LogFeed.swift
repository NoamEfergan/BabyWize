//
//  FeedIntent.swift
//  BabyWize
//
//  Created by Noam Efergan on 01/12/2022.
//

import Foundation
import AppIntents

// MARK: - LogFeed
struct LogFeed: AppIntent {
    @Inject private var dataManager: BabyDataManager
    static let intentClassName = "LogFeedIntent"

    static var title: LocalizedStringResource = "Log a feed"
    static var description = IntentDescription("Quickly and hands free log a feed")
    static var suggestedInvocationPhrase = "Log a feed on baby wize"

    @Parameter(title: "Amount", requestValueDialog: "How much?")
    var amount: Double?

    @Parameter(title: "Solid or liquid", requestValueDialog: "Is it a solid feed or a liquid feed?")
    var solidOrLiquid: IntentSolidOrLiquid?

    static var parameterSummary: some ParameterSummary {
        Summary("Add a \(\.$solidOrLiquid) feed of \(\.$amount) to my entries.")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // TODO: Place your refactored intent handler code here.
        guard let amount else {
            throw $amount.needsValueError("How much?")
        }
        guard let solidOrLiquid else {
            throw $solidOrLiquid.needsValueError("Is it a solid or a liquid feed?")
        }
        let newFeed = Feed(id: UUID().uuidString,
                           date: .now,
                           amount: amount,
                           note: nil,
                           solidOrLiquid: .init(rawValue: solidOrLiquid.rawValue) ?? .liquid)
        await dataManager.addFeed(newFeed)
        return .result(dialog: "Done! logged a \(solidOrLiquid.rawValue) feed of \(amount.description)")
    }
}

// MARK: - IntentSolidOrLiquid
enum IntentSolidOrLiquid: String, AppEnum {
    static var typeDisplayRepresentation = TypeDisplayRepresentation("SolidOrLiquid")

    static var caseDisplayRepresentations: [IntentSolidOrLiquid : DisplayRepresentation] =
        [
            .liquid : .init(stringLiteral: "Liquid"),
            .solid : .init(stringLiteral: "Solid")
        ]

    case liquid = "Liquid"
    case solid = "Solid"
}

private extension IntentDialog {
    static var AmountParameterPrompt: Self {
        "How much?"
    }

    static func AmountParameterDisambiguationIntro(count: Int, Amount: Double) -> Self {
        "There are \(count) options matching ‘\(Amount)’."
    }

    static func AmountParameterConfirmation(Amount: Double) -> Self {
        "Just to confirm, you wanted ‘\(Amount)’?"
    }

    static func responseSuccess(amount: Double) -> Self {
        "Logged a feed with \(amount)"
    }

    static var responseFailure: Self {
        "Failed to log a feed"
    }
}

