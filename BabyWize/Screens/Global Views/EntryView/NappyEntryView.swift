//
//  NappyEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

// MARK: - NappyEntryView
struct NappyEntryView: View {
    @EnvironmentObject private var vm: EntryViewModel
    @Environment(\.dynamicTypeSize) var typeSize
    var body: some View {
        VStack {
            AccessibleDatePicker(label: "When", value: $vm.changeDate)
                .padding()
            switch typeSize {
            case .xSmall, .small, .medium, .large, .xLarge , .xxLarge:
                HStack {
                    pickerTitle
                    picker
                        .pickerStyle(.segmented)
                }
            default:
                VStack {
                    pickerTitle
                    picker
                        .pickerStyle(.automatic)
                }
            }
        }
    }

    private var pickerTitle: some View {
        Text("Wet or soiled?")
    }

    private var picker: some View {
        Picker("Wet or soiled?", selection: $vm.wetOrSoiled) {
            ForEach(NappyChange.WetOrSoiled.allCases, id: \.self) { item in
                Text(item.rawValue).tag(item)
                    .font(.system(.body, design: .rounded))
            }
        }
    }
}

// MARK: - NappyEntryView_Previews
struct NappyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NappyEntryView()
            .environmentObject(EntryViewModel())
    }
}
