//
//  FeedEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

// MARK: - FeedEntryView
struct FeedEntryView: View {
    @EnvironmentObject private var vm: EntryViewModel

    var body: some View {
        VStack(alignment: .leading) {
            AccessibleDatePicker(label: "When", value: $vm.feedDate)
            AccessibleLabeledTextField(label: "Amount", hint: "Please enter an amount", value: $vm.amount)
                .keyboardType(.decimalPad)
            AccessibleLabeledTextField(label: "Notes", hint: "Milk, porridge, fruit etc...", value: $vm.feedNote)
        }
        .padding()
    }
}

// MARK: - FeedEntryView_Previews
struct FeedEntryView_Previews: PreviewProvider {
    static var previews: some View {
        FeedEntryView()
            .environmentObject(EntryViewModel())
    }
}
