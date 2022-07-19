//
//  Info View.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI
import Charts

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
                    Chart(dataManager.feedData) { feed in
                        LineMark(
                            x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                            y: .value("Amount", feed.amount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .interpolationMethod(.cardinal)
                    }
                    .frame(height: 200)
                    

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
