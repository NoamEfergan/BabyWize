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
                if let type = vm.type {
                    AccessibleLabeledContent(label:vm.averageTitle, value: dataManager.getAverage(for: type))
                    AccessibleLabeledContent(label:vm.largestTitle, value: dataManager.getBiggest(for: type))
                    AccessibleLabeledContent(label: vm.smallestTitle, value: dataManager.getSmallest(for: type))
                    NavigationLink("All inputs", value: vm.inputScreen)
                }
            }

            Section("total history") {
                switch vm.type {
                case .feed:
                    FeedChart(feedData: dataManager.feedData, showTitle: false)
                        .frame(height: 200)
                case .sleep:
                    SleepChart(sleepData: dataManager.sleepData, showTitle: false)
                        .frame(height: 200)
                default:
                    EmptyView()
                }
            }
        }
        .font(.system(.body, design: .rounded))
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
