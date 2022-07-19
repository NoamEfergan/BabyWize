//
//  InputDetailView.swift
//  BabyTracker
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
                        ForEach(dataManager.feedData, id: \.id) { feed in
                            VStack{
                                LabeledContent("Amount", value: feed.amount.roundDecimalPoint().description)
                                LabeledContent("Date", value: feed.date.formatted())
                            }
                            .sheet(isPresented: $isShowingEntryView) {
                                
                                EditEntryView(type: .feed, item: feed)
                                    .presentationDetents([.height(200)])
                                
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    isShowingEntryView.toggle()
                                    entryVM.setInitialValues(type: .feed, with: feed.specifier)
                                } label: {
                                    Text("Edit")
                                }
                                
                            }
                            .tint(.blue)
                        }
                        .onDelete { offsets in
                            dataManager.deleteItem(at: offsets, for: .feed)
                        }
                    }
                }

                
            case .sleep:
                List {
                    Section("Swipe right to edit, left to remove") {
                        ForEach(dataManager.sleepData, id: \.id) { sleep in
                            VStack{
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
                                    entryVM.setInitialValues(type: .sleep , with: sleep.specifier)
                                } label: {
                                    Text("Edit")
                                }
                                
                            }
                            .tint(.blue)
                        }
                        .onDelete { offsets in
                            dataManager.deleteItem(at: offsets, for: .feed)
                        }
                    }
                }
            case .nappy:
                List {
                    Section("Swipe right to edit, left to remove") {
                        ForEach(dataManager.nappyData, id: \.id) { change in
                            VStack{
                                LabeledContent("Date", value: change.dateTime.formatted())
                            }
                            .sheet(isPresented: $isShowingEntryView) {
                                
                                EditEntryView(type: .nappy, item: change)
                                    .presentationDetents([.height(200)])
                                
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    isShowingEntryView.toggle()
                                    entryVM.setInitialValues(type: .nappy , with: change.specifier)
                                } label: {
                                    Text("Edit")
                                }
                                
                            }
                            .tint(.blue)
                        }
                        .onDelete { offsets in
                            dataManager.deleteItem(at: offsets, for: .feed)
                        }
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
    }
    
}

struct InputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            InputDetailView(type: .feed)
                .environmentObject(EntryViewModel())
        }
        NavigationStack {
            InputDetailView(type: .sleep)
                .environmentObject(EntryViewModel())
        }
    }
}
