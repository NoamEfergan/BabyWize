//
//  EditEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI
import Models
import ViewModels
import EntryViews

// MARK: - EditEntryView
public struct EditEntryView<Item: DataItem, ViewModel: EntryViewModel>: View {
    @Environment(\.dismiss) var dismiss
    @State private var errorText = ""
    @ObservedObject var viewModel: ViewModel
    let type: EntryType
    var item: Item

    public init(viewModel: ViewModel, type: EntryType, item: Item) {
        self.viewModel = viewModel
        self.type = type
        self.item = item
    }

    public var body: some View {
        ScrollView {
            switch type {
            case .liquidFeed, .solidFeed:
                FeedEntryView(vm: viewModel as! FeedEntryViewModel)
            case .sleep:
                SleepEntryView(vm: viewModel as! SleepEntryViewModel)
            case .nappy:
                NappyEntryView(vm: viewModel as! NappyEntryViewModel)
            case .breastFeed:
                BreastFeedEntryView(vm: viewModel as! BreastFeedEntryViewModel)
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
                                 solidOrLiquid: .liquid))
        EditEntryView(viewModel: FeedEntryViewModel(),
                      type: .liquidFeed,
                      item: Feed(id: "1",
                                 date: .now,
                                 amount: 180,
                                 note: "test",
                                 solidOrLiquid: .liquid))
    }
}
