//
//  InfoScreenViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation
import Intents
import AppIntents
import Models
import Managers

public final class InfoScreenVM: ObservableObject {
    @InjectedObject private var dataManager: BabyDataManager

    @Published public var averageTitle: String = .nonAvailable
    @Published public var solidFeedAverageTitle: String = .nonAvailable
    @Published public var smallestTitle: String = .nonAvailable
    @Published public var largestTitle: String = .nonAvailable
    @Published public var solidFeedSmallestTitle: String = .nonAvailable
    @Published public var solidFeedLargestTitle: String = .nonAvailable
    @Published public var navigationTitle: String = .nonAvailable
    @Published public var sectionTitle: String = .nonAvailable
    @Published public var solidSectionTitle: String = .nonAvailable
    @Published public var screen: Screens = .sleep
    @Published public var inputScreen: Screens = .detailInputSleep

    @Published public var isShowingSiriRequest = false

    public var type: EntryType? {
        switch inputScreen {
        case .feed, .detailInputLiquidFeed:
            return .liquidFeed
        case .sleep, .detailInputSleep:
            return .sleep
        default:
            return nil
        }
    }

    public var siriRequestTitle = "You're going to need to allow Siri in order to use these shortcuts"

    public init(screen: Screens) {
        self.screen = screen
        inputScreen = screen == .feed ? .detailInputLiquidFeed : .detailInputSleep
        setTitles()
    }

    public func requestSiriOrShowError() {
        INPreferences.requestSiriAuthorization { [weak self] status in
            guard let self else {
                return
            }
            switch status {
            case .authorized:
                self.isShowingSiriRequest = false
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
