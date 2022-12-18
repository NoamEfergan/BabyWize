//
//  FeedEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

// MARK: - FeedEntryView
struct FeedEntryView: View {
    @ObservedObject var vm: FeedEntryViewModel

    var body: some View {
        VStack(alignment: .leading) {
            AccessiblePicker(title: "Solid or liquid?",
                             selection: $vm.solidOrLiquid) {
                ForEach(Feed.SolidOrLiquid.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                        .accessibilityLabel($0.rawValue)
                        .accessibilityAddTraits(.isButton)
                }
            }
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
        FeedEntryView(vm: .init())
    }
}
