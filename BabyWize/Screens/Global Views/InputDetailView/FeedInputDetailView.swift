//
//  FeedInputDetailView.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import SwiftUI

// MARK: - FeedInputDetailView
struct FeedInputDetailView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @StateObject var entryVM: FeedEntryViewModel = .init()
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false

    var body: some View {
        List {
            Section("Swipe right to edit, left to remove") {
                ForEach(dataManager.feedData) { feed in
                    VStack(alignment: .leading) {
                        AccessibleLabeledContent(label:"Amount",
                                                 value: feed.amount.displayableAmount(isSolid: feed.isSolids))
                        AccessibleLabeledContent(label:"Date", value: feed.date.formatted())
                        AccessibleLabeledContent(label:"Type", value: feed.solidOrLiquid.rawValue.capitalized)
                        if let note = feed.note, !note.isEmpty {
                            AccessibleLabeledContent(label:"Notes", value: feed.note ?? "n/a")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            isShowingEntryView.toggle()
                            entryVM.setInitialValues(with: feed.id.description)
                        } label: {
                            Text("Edit")
                        }
                    }
                    .tint(.blue)
                    .sheet(isPresented: $isShowingEntryView) {
                        EditEntryView(viewModel: entryVM,type: .liquidFeed, item: feed)
                            .presentationDetents([.height(200)])
                    }
                }
                .onDelete { offsets in
                    dataManager.removeFeed(at: offsets)
                }
            }
        }
        .onDisappear {
            entryVM.reset()
        }
    }
}

// MARK: - FeedInputDetailView_Previews
struct FeedInputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FeedInputDetailView()
    }
}
