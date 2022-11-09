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
    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        VStack(alignment: .leading) {
            picker
            AccessibleDatePicker(label: "When", value: $vm.feedDate)
            AccessibleLabeledTextField(label: "Amount", hint: "Please enter an amount", value: $vm.amount)
                .keyboardType(.decimalPad)
            AccessibleLabeledTextField(label: "Notes", hint: "Milk, porridge, fruit etc...", value: $vm.feedNote)
        }
        .padding()
    }

    @ViewBuilder
    private var picker: some View {
        switch typeSize {
        case .xSmall, .small, .medium, .large, .xLarge , .xxLarge:
            Picker("Solid or liquid?", selection: $vm.solidOrLiquid) {
                ForEach(Feed.SolidOrLiquid.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
        default:
            Picker("Solid or liquid?", selection: $vm.solidOrLiquid) {
                ForEach(Feed.SolidOrLiquid.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.automatic)
        }
    }


    @ViewBuilder
    private var entryPicker: some View {
        switch typeSize {
        case .xSmall, .small, .medium, .large, .xLarge , .xxLarge:
            HStack {
                picker
            }
        default:
            VStack {
                Text("Solid or liquid?")
                    .font(.system(.body, design: .rounded))
                picker
            }
        }
    }
}

// MARK: - FeedEntryView_Previews
struct FeedEntryView_Previews: PreviewProvider {
    static var previews: some View {
        FeedEntryView(vm: .init())
    }
}
