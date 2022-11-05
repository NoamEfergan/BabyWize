//
//  SleepInputDetailView.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import SwiftUI

// MARK: - SleepInputDetailView
struct SleepInputDetailView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @StateObject var entryVM: SleepEntryViewModel = .init()
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false

    var body: some View {
        List {
            Section("Swipe right to edit, left to remove") {
                ForEach(dataManager.sleepData, id: \.id) { sleep in
                    VStack(alignment: .leading) {
                        AccessibleLabeledContent(label:"Duration", value: sleep.duration)
                        AccessibleLabeledContent(label:"Date", value: sleep.date.formatted())
                    }
                    .sheet(isPresented: $isShowingEntryView) {
                        EditEntryView(viewModel: entryVM,type: .sleep, item: sleep)
                            .presentationDetents([.height(200)])
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            isShowingEntryView.toggle()
                            entryVM.setInitialValues(with: sleep.id.description)
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
        .onDisappear {
            entryVM.reset()
        }
    }
}

// MARK: - SleepInputDetailView_Previews
struct SleepInputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SleepInputDetailView()
    }
}
