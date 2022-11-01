//
//  InputDetailView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

struct InputDetailView: View {
    let type: EntryType
    @InjectedObject private var dataManager: BabyDataManager
    @EnvironmentObject private var entryVM: EntryViewModel
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false

    var body: some View {
        VStack {
            switch type {
            case .feed:
                List {
                    Section("Swipe right to edit, left to remove") {
                        ForEach(dataManager.feedData) { feed in
                            VStack {
                                LabeledContent("Amount", value: feed.amount.roundDecimalPoint().feedDisplayableAmount().description)
                                LabeledContent("Date", value: feed.date.formatted())
                                if let note = feed.note, !note.isEmpty {
                                    LabeledContent("Notes", value: feed.note ?? "n/a")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    isShowingEntryView.toggle()
                                    entryVM.setInitialValues(type: .feed, with: feed.id.description)
                                } label: {
                                    Text("Edit")
                                }
                            }
                            .tint(.blue)
                            .sheet(isPresented: $isShowingEntryView) {
                                EditEntryView(type: .feed, item: feed)
                                    .presentationDetents([.height(200)])
                            }
                        }
                        .onDelete { offsets in
                            dataManager.removeFeed(at: offsets)
                        }
                    }
                }

            case .sleep:
                List {
                    Section("Swipe right to edit, left to remove") {
                        ForEach(dataManager.sleepData, id: \.id) { sleep in
                            VStack {
                                LabeledContent("Duration", value: sleep.duration)
                                LabeledContent("Date", value: sleep.date.formatted())
                            }
                            .sheet(isPresented: $isShowingEntryView) {
                                EditEntryView(type: .sleep, item: sleep)
                                    .presentationDetents([.height(200)])
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    isShowingEntryView.toggle()
                                    entryVM.setInitialValues(type: .sleep, with: sleep.id.description)
                                } label: {
                                    Text("Edit")
                                }
                            }
                            .tint(.blue)
                        }
                        .onDelete { offsets in
                            dataManager.removeSleep(at: offsets)
                        }
                    }
                }
            case .nappy:
                List {
                    Section("Swipe right to edit, left to remove") {
                        ForEach(dataManager.nappyData, id: \.id) { change in
                            VStack {
                                LabeledContent("Date", value: change.dateTime.formatted())
                                LabeledContent("Wet or soiled", value: change.wetOrSoiled.rawValue)
                            }
                            .sheet(isPresented: $isShowingEntryView) {
                                EditEntryView(type: .nappy, item: change)
                                    .presentationDetents([.height(200)])
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    isShowingEntryView.toggle()
                                    entryVM.setInitialValues(type: .nappy, with: change.id.description)
                                } label: {
                                    Text("Edit")
                                }
                            }
                            .tint(.blue)
                        }
                        .onDelete { offsets in
                            dataManager.removeChange(at: offsets)
                        }
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .onDisappear {
            entryVM.reset()
        }
    }
}

struct InputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InputDetailView(type: .feed)
                .environmentObject(EntryViewModel())
        }
        NavigationStack {
            InputDetailView(type: .sleep)
                .environmentObject(EntryViewModel())
        }
        NavigationStack {
            InputDetailView(type: .nappy)
                .environmentObject(EntryViewModel())
        }
    }
}
