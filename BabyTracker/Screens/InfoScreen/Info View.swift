//
//  Info View.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

final class InfoScreenVM: ObservableObject {
    @InjectedObject private var dataManager: BabyDataManager

    @Published var averageTitle = ""
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
        navigationTitle = "\(screen.rawValue.capitalized) info"
        averageTitle = "Average \(screen)"
    }
    
}

struct InfoView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @ObservedObject var vm: InfoScreenVM
    var body: some View {
        List {
            Section("general") {
                LabeledContent(vm.averageTitle, value: dataManager.getAverage(for: vm.type))
                NavigationLink("All inputs", value: vm.inputScreen)
            }
        }
        .navigationTitle(vm.navigationTitle)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InfoView(vm: .init(screen: .sleep))
        }
        NavigationStack {
            InfoView(vm: .init(screen: .feed))
        }
    }
}
