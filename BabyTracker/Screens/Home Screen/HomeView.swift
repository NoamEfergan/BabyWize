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

struct HomeView: View {
    @Inject private var feedManager: FeedManager
    @Inject private var sleepManager: SleepManager
    @Inject private var nappyManager: NappyManager
    @State private var path: [Screens] = []
    @State private var isShowingNewEntrySheet: Bool = false
    @State private var isShowingSettings: Bool = false
    @ObservedObject private var entryVM = NewEntryViewModel()

    var body: some View {
        NavigationStack() {
            List {
                Section("recent info") {
                    LabeledContent(
                        "Last Feed",
                        value: feedManager.data.last?.amount.roundDecimalPoint().feedDisplayableAmount() ?? "None recorded"
                    )
                    LabeledContent("Last Nappy change", value: nappyManager.data.last?.dateTime.formatted() ?? "None recorded")
                    LabeledContent("Last Sleep", value: sleepManager.data.last?.duration ?? "None recorded")
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
                    .presentationDetents([.fraction(0.3)])
            }
            .navigationDestination(for: Screens.self) { screen in
                switch screen {
                case .settings:
                    SettingsView()
                        
                default:
                    EmptyView()
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
