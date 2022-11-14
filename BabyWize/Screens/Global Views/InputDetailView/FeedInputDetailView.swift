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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject var entryVM: FeedEntryViewModel = .init()
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false
    @State private var presentableData: [Feed] = []
    var solidOrLiquid: Feed.SolidOrLiquid


    var body: some View {
        List {
            Section("Swipe right to edit, left to remove") {
                ForEach(presentableData) { feed in
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
                            .presentationDetents([.fraction(0.4), .medium])
                    }
                }
                .onDelete { offsets in
                    dataManager.removeFeed(at: offsets)
                    setPresentableData()
                }
                .onChange(of: presentableData) { newValue in
                    if newValue.isEmpty {
                        if dataManager.feedData.isEmpty {
                            navigationVM.path.removeAll()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            setPresentableData()
        }

        .onDisappear {
            entryVM.reset()
        }
    }

    private func setPresentableData() {
        presentableData = dataManager.feedData.filter({ $0.solidOrLiquid == solidOrLiquid })
    }
}

// MARK: - FeedInputDetailView_Previews
struct FeedInputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FeedInputDetailView(solidOrLiquid: .solid)
        FeedInputDetailView(solidOrLiquid: .liquid)
    }
}