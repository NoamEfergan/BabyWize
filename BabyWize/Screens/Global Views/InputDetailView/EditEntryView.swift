//
//  EditEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

// MARK: - EditEntryView
struct EditEntryView<Item: DataItem, ViewModel: EntryViewModel>: View {
    @Environment(\.dismiss) var dismiss
    @State private var errorText = ""
    @ObservedObject var viewModel: ViewModel
    let type: EntryType
    var item: Item

    var body: some View {
        ScrollView {
            switch type {
            case .liquidFeed, .solidFeed:
                FeedEntryView(vm: viewModel as! FeedEntryViewModel)
            case .sleep:
                SleepEntryView(vm: viewModel as! SleepEntryViewModel)
            case .nappy:
                NappyEntryView(vm: viewModel as! NappyEntryViewModel)
            }
            if !errorText.isEmpty {
                Text(errorText)
                    .foregroundColor(.red)
            }
            Button("Edit") {
                do {
                    try viewModel.editEntry()
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
        .onChange(of: type, perform: { _ in
            errorText = ""
        })
        .animation(.easeIn, value: errorText)
        .animation(.easeIn, value: type)
    }
}

// MARK: - EditEntryView_Previews
struct EditEntryView_Previews: PreviewProvider {
    static var previews: some View {
        EditEntryView(viewModel: FeedEntryViewModel(),
                      type: .liquidFeed,
                      item: Feed(id: "1",
                                 date: .now,
                                 amount: 180,
                                 note: "test",
                                 solidOrLiquid: .liquid(type: .formula)))
        EditEntryView(viewModel: FeedEntryViewModel(),
                      type: .liquidFeed,
                      item: Feed(id: "1",
                                 date: .now,
                                 amount: 180,
                                 note: "test",
                                 solidOrLiquid: .liquid(type: .breast)))
    }
}
