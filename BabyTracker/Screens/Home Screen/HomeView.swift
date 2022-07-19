//
//  HomeView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 17/07/2022.
//

import Charts
import SwiftUI

struct HomeView: View {
    @Inject private var feedManager: FeedManager
    @Inject private var sleepManager: SleepManager
    @Inject private var nappyManager: NappyManager

    @State private var isShowingNewEntrySheet: Bool = false
    @ObservedObject private var entryVM = NewEntryViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("recent info") {
                    LabeledContent(
                        "Last Feed",
                        value: feedManager.data.first?.amount.roundDecimalPoint().feedDisplayableAmount() ?? "None recorded"
                    )
                    LabeledContent("Last Nappy change", value: "12:43 pm")
                    LabeledContent("Last Sleep", value: "1 hr 07 mins")
                }
                HomeScreenSections()
            }
            .toolbar {
                Button {
                    isShowingNewEntrySheet.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            .navigationTitle("Baby Tracker")
            .sheet(isPresented: $isShowingNewEntrySheet) {
                AddEntryView()
                    .environmentObject(entryVM)
                    .presentationDetents([.fraction(0.3)])
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
