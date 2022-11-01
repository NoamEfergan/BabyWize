//
//  FeedEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

struct FeedEntryView: View {
    @EnvironmentObject private var vm: EntryViewModel

    var body: some View {
        VStack {
            DatePicker("When", selection: $vm.feedDate)
                .datePickerStyle(.compact)
            LabeledContent("Amount") {
                TextField("Please enter an amount", text: $vm.amount)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            LabeledContent("Notes") {
                TextField("Milk, porridge, fruit etc... ", text: $vm.feedNote)
                    .textFieldStyle(.roundedBorder)
            }

        }
        .padding()
    }
}

struct FeedEntryView_Previews: PreviewProvider {
    static var previews: some View {
        FeedEntryView()
            .environmentObject(EntryViewModel())
    }
}
