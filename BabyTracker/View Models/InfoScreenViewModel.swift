//
//  InfoScreenViewModel.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import Foundation

final class InfoScreenVM: ObservableObject {
    @InjectedObject private var dataManager: BabyDataManager

    @Published var averageTitle = ""
    @Published var smallestTitle = ""
    @Published var largestTitle = ""
    @Published var navigationTitle = ""
    @Published var screen: InfoScreens = .sleep
    @Published var inputScreen: InfoScreens = .detailInputSleep

    var type: EntryType {
        switch inputScreen {
        case .feed,.detailInputFeed:
            return .feed
        case .sleep, .detailInputSleep:
            return .sleep
        }
    }

    init(screen: InfoScreens) {
        self.screen = screen
        inputScreen = screen == .feed ? .detailInputFeed : .detailInputSleep
        setTitles()
    }
    
    private func setTitles() {
        averageTitle = "Average \(screen)"
        navigationTitle = "\(screen.rawValue.capitalized) info"
        switch type {
        case .feed:
            largestTitle = "Largest feed"
            smallestTitle = "Smallest feed"
        case .sleep:
            largestTitle = "Longest sleep"
            smallestTitle = "Shortest sleep"
        case .nappy:
            return
        }
    }
    
}
