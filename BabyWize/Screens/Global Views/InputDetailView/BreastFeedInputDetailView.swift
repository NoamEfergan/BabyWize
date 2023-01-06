//
//  BreastFeedInputDetailView.swift
//  BabyWize
//
//  Created by Noam Efergan on 06/01/2023.
//

import SwiftUI

// MARK: - BreastFeedInputDetailView
struct BreastFeedInputDetailView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject var entryVM: BreastFeedEntryViewModel = .init()
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false
    @State private var isShowingAlert = false

    var body: some View {
        List {
            Section {
                ForEach(dataManager.breastFeedData, id: \.id) { feed in
                    VStack(alignment: .leading) {
                        AccessibleLabeledContent(label:"Duration", value: feed.getDisplayableString())
                        AccessibleLabeledContent(label:"Date", value: feed.date.formatted())
                    }
                    .sheet(isPresented: $isShowingEntryView) {
                        EditEntryView(viewModel: entryVM,type: .breastFeed, item: feed)
                            .presentationDetents([.fraction(0.4), .medium])
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
                }
                .onDelete { offsets in
                    dataManager.removeBreastFeed(at: offsets)
                }
            } header: {
                Text("Swipe right to edit, left to remove")
            } footer: {
                Button("Remove All") {
                    isShowingAlert.toggle()
                }
                .foregroundColor(.red)
            }
            .confirmationDialog("Remove All", isPresented: $isShowingAlert) {
                Button(role: .destructive) {
                    dataManager.removeAll(for: .breastFeed)
                } label: {
                    Text("Yes")
                }

                Button("No") {
                    isShowingAlert.toggle()
                }
            } message: {
                Text("Are you sure you want to remove all? this CANNOT be undone! ")
            }
        }
        .onDisappear {
            entryVM.reset()
        }
        .onChange(of: dataManager.breastFeedData) { newValue in
            if newValue.isEmpty {
                navigationVM.path.removeAll()
            }
        }
    }
}

// MARK: - BreastFeedInputDetailView_Previews
struct BreastFeedInputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BreastFeedInputDetailView()
    }
}
