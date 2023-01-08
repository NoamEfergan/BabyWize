//
//  Info View.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import AppIntents
import Charts
import SwiftUI


// MARK: - InfoView
struct InfoView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @ObservedObject var vm: InfoScreenVM

    private var shouldShowAllInputs: Bool {
        guard let type = vm.type else {
            return false
        }
        return dataManager.getAverage(for: type) != .nonAvailable
            && dataManager.getBiggest(for: type) != .nonAvailable
            && dataManager.getSmallest(for: type) != .nonAvailable
    }

    var body: some View {
        List {
            if let type = vm.type {
                Section(vm.sectionTitle) {
                    AccessibleLabeledContent(label:vm.averageTitle, value: dataManager.getAverage(for: type))
                    AccessibleLabeledContent(label:vm.largestTitle, value: dataManager.getBiggest(for: type))
                    AccessibleLabeledContent(label: vm.smallestTitle, value: dataManager.getSmallest(for: type))
                    if shouldShowAllInputs {
                        NavigationLink("All inputs", value: vm.inputScreen)
                    }
                }
                if type == .liquidFeed {
                    if !dataManager.feedData.filter(\.isSolids).isEmpty {
                        Section(vm.solidSectionTitle) {
                            AccessibleLabeledContent(label:vm.solidFeedAverageTitle,
                                                     value: dataManager.getAverage(for: .solidFeed))
                            AccessibleLabeledContent(label:vm.solidFeedLargestTitle,
                                                     value: dataManager.getBiggest(for: .solidFeed))
                            AccessibleLabeledContent(label: vm.solidFeedSmallestTitle,
                                                     value: dataManager.getSmallest(for: .solidFeed))
                            NavigationLink("All inputs", value: Screens.detailInputSolidFeed)
                        }
                    }

                    if !dataManager.breastFeedData.isEmpty {
                        Section("Breast feeds") {
                            AccessibleLabeledContent(label:"Average feed",
                                                     value: dataManager.getAverage(for: .breastFeed))
                            AccessibleLabeledContent(label: "Longest feed",
                                                     value: dataManager.getBiggest(for: .breastFeed))
                            AccessibleLabeledContent(label: "Shortest feed",
                                                     value: dataManager.getSmallest(for: .breastFeed))
                            NavigationLink("All inputs", value: Screens.detailInputBreastFeed)
                        }
                    }
                }
            }
            Section("total history") {
                switch vm.type {
                case .liquidFeed:
                    FeedChart(feedData: dataManager.feedData, breastFeedData: [], showTitle: false)
                        .frame(minHeight: 200)
                case .sleep:
                    SleepChart(sleepData: dataManager.sleepData, showTitle: false)
                        .frame(minHeight: 200)
                default:
                    EmptyView()
                }
            }
            siriView
        }
        .alert(vm.siriRequestTitle, isPresented: $vm.isShowingSiriRequest) {
            Button(role: .cancel) {
                vm.isShowingSiriRequest.toggle()
            } label: {
                Text("Ok")
            }
        }
        .font(.system(.body, design: .rounded))
        .navigationTitle(vm.navigationTitle)
    }

    @ViewBuilder
    private var siriView: some View {
        Group {
            switch vm.type {
            case .liquidFeed, .solidFeed:
                SiriTipView(intent: LogFeed())
            case .sleep:
                SiriTipView(intent: LogSleep())
            default:
                EmptyView()
            }
        }
        .onTapGesture {
            vm.requestSiriOrShowError()
        }
        .siriTipViewStyle(.dark)
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
