//
//  NappyInputDetailView.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import SwiftUI

// MARK: - NappyInputDetailView
struct NappyInputDetailView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject var entryVM: NappyEntryViewModel = .init()
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false
    @State private var isShowingAlert = false

    var body: some View {
        List {
            Section {
                ForEach(dataManager.nappyData, id: \.id) { change in
                    VStack(alignment: .leading) {
                        AccessibleLabeledContent(label:"Date", value: change.dateTime.formatted())
                        AccessibleLabeledContent(label:"Wet or soiled", value: change.wetOrSoiled.rawValue)
                    }
                    .sheet(isPresented: $isShowingEntryView) {
                        EditEntryView(viewModel: entryVM, type: .nappy, item: change)
                            .presentationDetents([.fraction(0.4), .medium])
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            isShowingEntryView.toggle()
                            entryVM.setInitialValues(with: change.id)
                        } label: {
                            Text("Edit")
                        }
                    }
                    .tint(.blue)
                }
                .onDelete { offsets in
                    dataManager.removeChange(at: offsets)
                }
            } header: {
                Text("Swipe right to edit, left to remove")
            }
            footer: {
                Button("Remove All") {
                    isShowingAlert.toggle()
                }
                .foregroundColor(.red)
            }
            .confirmationDialog("Remove All", isPresented: $isShowingAlert) {
                Button(role: .destructive) {
                    dataManager.removeAll(for: .nappy)
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
        .onChange(of: dataManager.nappyData) { newValue in
            if newValue.isEmpty {
                navigationVM.path.removeAll()
            }
        }
    }
}

// MARK: - NappyInputDetailView_Previews
struct NappyInputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NappyInputDetailView()
    }
}
