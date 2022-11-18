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
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject var entryVM: SleepEntryViewModel = .init()
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false
    @State private var isShowingAlert = false

    var body: some View {
        List {
            Section {
                ForEach(dataManager.sleepData, id: \.id) { sleep in
                    VStack(alignment: .leading) {
                        AccessibleLabeledContent(label:"Duration", value: sleep.getDisplayableString())
                        AccessibleLabeledContent(label:"Date", value: sleep.date.formatted())
                    }
                    .sheet(isPresented: $isShowingEntryView) {
                        EditEntryView(viewModel: entryVM,type: .sleep, item: sleep)
                            .presentationDetents([.fraction(0.4), .medium])
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
                    dataManager.removeAll(for: .sleep)
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
        .onChange(of: dataManager.sleepData) { newValue in
            if newValue.isEmpty {
                navigationVM.path.removeAll()
            }
        }
    }
}

// MARK: - SleepInputDetailView_Previews
struct SleepInputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SleepInputDetailView()
    }
}
