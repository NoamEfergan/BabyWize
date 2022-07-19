//
//  FeedEntryView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

struct FeedEntryView: View {
    @EnvironmentObject private var vm: NewEntryViewModel

    var body: some View {
        VStack {
            DatePicker("When", selection: $vm.feedDate)
                .datePickerStyle(.compact)
            LabeledContent("Amount") {
                TextField("Please enter an amount", text: $vm.amount)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
        }
        .padding()
    }
}

struct FeedEntryView_Previews: PreviewProvider {
    static var previews: some View {
        FeedEntryView()
            .environmentObject(NewEntryViewModel())
    }
}
