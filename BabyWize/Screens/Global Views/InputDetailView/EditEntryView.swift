//
//  EditEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

struct EditEntryView<Item: DataItem>: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: EntryViewModel
    @State private var errorText: String = ""
    let type: EntryType
    var item: Item

    var body: some View {
        VStack(spacing: 15) {
            switch type {
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
            Button("Edit") {
                do {
                    try vm.editEntry(type: type)
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
        .onChange(of: type, perform: { _ in
            errorText = ""
        })
        .animation(.easeIn, value: errorText)
        .animation(.easeIn, value: type)
    }
}

struct EditEntryView_Previews: PreviewProvider {
    static var previews: some View {
        EditEntryView(type: .feed, item: Feed(id: "1", date: .now, amount: 180, note: "test"))
            .environmentObject(EntryViewModel())
    }
}
