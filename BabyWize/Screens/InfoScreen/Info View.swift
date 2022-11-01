//
//  Info View.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import Charts
import SwiftUI

// MARK: - InfoView
struct InfoView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @ObservedObject var vm: InfoScreenVM
    var body: some View {
        List {
            Section("general") {
                LabeledContent(vm.averageTitle, value: dataManager.getAverage(for: vm.type))
                LabeledContent(vm.largestTitle, value: dataManager.getBiggest(for: vm.type))
                LabeledContent(vm.smallestTitle, value: dataManager.getSmallest(for: vm.type))
                NavigationLink("All inputs", value: vm.inputScreen)
            }

            Section("total history") {
                switch vm.type {
                case .feed:
                    FeedChart(feedData: dataManager.feedData, showTitle: false)
                        .frame(height: 200)
                case .sleep:
                    SleepChart(sleepData: dataManager.sleepData, showTitle: false)
                        .frame(height: 200)
                case .nappy:
                    EmptyView()
                }
            }
        }
        .navigationTitle(vm.navigationTitle)
    }
}

// MARK: - InfoView_Previews
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
