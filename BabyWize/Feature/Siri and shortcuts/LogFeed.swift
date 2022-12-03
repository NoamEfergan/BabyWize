//
//  FeedIntent.swift
//  BabyWize
//
//  Created by Noam Efergan on 01/12/2022.
//

import Foundation
import AppIntents

// MARK: - LogFeed
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct LogFeed: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "LogFeedIntent"

    static var title: LocalizedStringResource = "Log a feed"
    static var description = IntentDescription("Quickly and hands free log a feed")
    static var suggestedInvocationPhrase = "Log a feed"
    
    @Parameter(title: "Amount")
    var amount: Double?

    @Parameter(title: "Solid or liquid")
    var solidOrLiquid: IntentSolidOrLiquid?

    static var parameterSummary: some ParameterSummary {
        Summary("Add a \(\.$solidOrLiquid) feed of \(\.$amount) to my entries.")
    }

    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        guard let amount else {
            throw $amount.needsValueError("How much?")
        }
        guard let solidOrLiquid else {
            throw $solidOrLiquid.needsValueError("Is it a solid or a liquid feed?")
        }
        return .result(dialog: "Done! logged a \(solidOrLiquid.rawValue) feed of \(amount)")
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

