//
//  HomeView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 17/07/2022.
//

import Charts
import SwiftUI

enum Screens: String {
    case home, settings, newEntry
}

enum InfoScreens: String {
    case feed, sleep, detailInputFeed, detailInputSleep
}

struct HomeView: View {
    @InjectedObject private var dataManager: BabyDataManager
//    @InjectedObject private var 
    @State private var path: [Screens] = []
    @State private var isShowingNewEntrySheet: Bool = false
    @State private var isShowingSettings: Bool = false
    @ObservedObject private var entryVM = EntryViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("recent info") {
                    LabeledContent(
                        "Last Feed",
                        value: dataManager.feedData.last?.amount.roundDecimalPoint().feedDisplayableAmount() ?? "None recorded"
                    )
                    LabeledContent("Last Nappy change", value: dataManager.nappyData.last?.dateTime.formatted() ?? "None recorded")
                    LabeledContent("Last Sleep", value: dataManager.sleepData.last?.duration ?? "None recorded")
                }
                HomeScreenSections()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(value: Screens.settings) {
                        Image(systemName: "gear")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isShowingNewEntrySheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .navigationTitle("Baby Tracker")
            .sheet(isPresented: $isShowingNewEntrySheet) {
                AddEntryView()
                    .environmentObject(entryVM)
                    .presentationDetents([.height(270)])
            }
            .navigationDestination(for: Screens.self) { screen in
                switch screen {
                case .settings:
                    SettingsView()
                default:
                    EmptyView()
                }
            }
            .navigationDestination(for: InfoScreens.self) { screen in
                switch screen {
                case .feed, .sleep:
                    InfoView(vm: .init(screen: screen))
                case .detailInputSleep:
                    InputDetailView(type: .sleep)
                        .navigationTitle("All sleeps")
                        .environmentObject(entryVM)
                case .detailInputFeed:
                    InputDetailView(type: .feed)
                        .navigationTitle("All feeds")
                        .environmentObject(entryVM)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}