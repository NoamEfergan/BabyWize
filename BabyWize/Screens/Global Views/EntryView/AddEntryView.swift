//
//  AddEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: EntryViewModel
    @State private var startDate: Date = .init()
    @State private var endDate: Date = .init()
    @State private var errorText: String = ""
    @State private var entryType: EntryType = .feed

    var body: some View {
        VStack(spacing: 15) {
            Picker("Entry Type", selection: $entryType) {
                ForEach(EntryType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            switch entryType {
            case .feed:
                FeedEntryView()
            case .sleep:
                SleepEntryView()
            case .nappy:
                NappyEntryView()
            }
            if !errorText.isEmpty {
                Text(errorText)
                    .foregroundColor(.red)
            }
            Button("Add") {
                do {
                    try vm.addEntry(type: entryType)
                    dismiss()
                } catch {
                    guard let entryError = error as? EntryViewModel.EntryError else {
                        errorText = "Whoops! something went wrong!"
                        return
                    }
                    errorText = entryError.errorText
                }
            }.buttonStyle(.borderedProminent)
        }
        .padding()
        .onChange(of: entryType, perform: { _ in
            errorText = ""
        })
        .animation(.easeIn, value: errorText)
        .animation(.easeIn, value: entryType)
    }
}

struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView()
            .environmentObject(EntryViewModel())
    }
}
