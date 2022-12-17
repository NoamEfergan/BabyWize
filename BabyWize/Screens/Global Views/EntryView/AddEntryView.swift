//
//  AddEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

// MARK: - AddEntryView
struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var feedVM: FeedEntryViewModel = .init()
    @StateObject var sleepVM: SleepEntryViewModel = .init()
    @StateObject var nappyVM: NappyEntryViewModel = .init()
    @State private var startDate: Date = .init()
    @State private var endDate: Date = .init()
    @State private var errorText = ""
    @State private var entryType: EntryType = .liquidFeed

    var body: some View {
        ScrollView {
            AccessiblePicker(title: "Entry type?",
                             selection: $entryType,
                             data: EntryType.allCases.filter({ $0 != .solidFeed }).compactMap({ $0.title }))
            switch entryType {
            case .liquidFeed, .solidFeed:
                FeedEntryView(vm: feedVM)
            case .sleep:
                SleepEntryView(vm: sleepVM)
            case .nappy:
                NappyEntryView(vm: nappyVM)
            }
            if !errorText.isEmpty {
                Text(errorText)
                    .foregroundColor(.red)
                    .accessibilityLabel("Error")
                    .accessibilityValue(errorText)
            }
            Button("Add") {
                do {
                    switch entryType {
                    case .liquidFeed, .solidFeed:
                        try feedVM.addEntry()
                    case .sleep:
                        try sleepVM.addEntry()
                    case .nappy:
                        try nappyVM.addEntry()
                    }
                    dismiss()
                } catch {
                    guard let entryError = error as? EntryError else {
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
        .animation(.easeInOut, value: entryType)
    }
}

// MARK: - AddEntryView_Previews
struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView()
    }
}
