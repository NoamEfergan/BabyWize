//
//  AddEntryView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

struct AddEntryView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: NewEntryViewModel
    @State private var entryType: EntryType = .feed
    @State private var startDate: Date = .init()
    @State private var endDate: Date = .init()
    @State private var errorText: String = ""
    
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
            Button("Send") {
                do {
                    try vm.addEntry(type: entryType)
                    dismiss()
                } catch {
                    guard let entryError = error as? NewEntryViewModel.EntryError else {
                        errorText = "Whoops! something went wrong!"
                        return
                    }
                    errorText = entryError.errorText
                }
            }.buttonStyle(.borderedProminent)
        }
        .padding()
        .onChange(of: entryType, perform: { newValue in
            errorText = ""
        })
        .animation(.easeIn, value: errorText)
        .animation(.easeIn, value: entryType)
    }
}

struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView()
            .environmentObject(NewEntryViewModel())
    }
}
