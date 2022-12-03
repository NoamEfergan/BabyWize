//
//  InfoScreenViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import Intents
import AppIntents

final class InfoScreenVM: ObservableObject {
    @InjectedObject private var dataManager: BabyDataManager

    @Published var averageTitle: String = .nonAvailable
    @Published var solidFeedAverageTitle: String = .nonAvailable
    @Published var smallestTitle: String = .nonAvailable
    @Published var largestTitle: String = .nonAvailable
    @Published var solidFeedSmallestTitle: String = .nonAvailable
    @Published var solidFeedLargestTitle: String = .nonAvailable
    @Published var navigationTitle: String = .nonAvailable
    @Published var sectionTitle: String = .nonAvailable
    @Published var solidSectionTitle: String = .nonAvailable
    @Published var screen: Screens = .sleep
    @Published var inputScreen: Screens = .detailInputSleep

    @Published var isShowingSiriRequest = false

    var type: EntryType? {
        switch inputScreen {
        case .feed, .detailInputLiquidFeed:
            return .liquidFeed
        case .sleep, .detailInputSleep:
            return .sleep
        default:
            return nil
        }
    }

    var siriRequestTitle = "You're going to need to allow Siri in order to use these shortcuts"

    init(screen: Screens) {
        self.screen = screen
        inputScreen = screen == .feed ? .detailInputLiquidFeed : .detailInputSleep
        setTitles()
    }

    func addUserActivity() {
//        let identifier = "LogFeedIntent"
//        let userActivity = NSUserActivity(activityType: identifier)
//        let title = "Quickly and hands free log a feed!"
//        userActivity.title = title
//        userActivity.suggestedInvocationPhrase = "Log a feed"
//        userActivity.isEligibleForPrediction = true
//        userActivity.persistentIdentifier = identifier
//        let shortcut = INShortcut(userActivity: userActivity)
//        IntentDonationManager.shared.donate(intent: LogFeed())
        Task {
            do {
                let intent = LogFeed()
                try await IntentDonationManager.shared.donate(intent: intent)
            } catch {
                print("Failed with error: \(error.localizedDescription)")
            }
        }
    }

    func requestSiriOrShowError() {
        INPreferences.requestSiriAuthorization { [weak self] status in
            guard let self else {
                return
            }
            switch status {
            case .authorized:
                self.isShowingSiriRequest = false
                self.addUserActivity()
            default:
                self.isShowingSiriRequest = true
            }
        }
    }

    private func setTitles() {
        navigationTitle = "\(screen.rawValue.capitalized) info"
        switch type {
        case .liquidFeed:
            sectionTitle = "liquid feeds"
            solidSectionTitle = "solid feed"
            averageTitle = "Average liquid \(screen)"
            solidFeedAverageTitle = "Average solid \(screen)"
            largestTitle = "Largest liquid feed"
            smallestTitle = "Smallest liquid feed"
            solidFeedLargestTitle = "Largest solid feed"
            solidFeedSmallestTitle = "Smallest solid feed"
        case .sleep:
            sectionTitle = "general"
            averageTitle = "Average \(screen)"
            largestTitle = "Longest sleep"
            smallestTitle = "Shortest sleep"
        default:
            return
        }
    }
}
