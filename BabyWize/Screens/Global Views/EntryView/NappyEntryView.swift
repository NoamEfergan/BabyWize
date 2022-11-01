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
    var body: some View {
        VStack {
            DatePicker("When", selection: $vm.changeDate)
                .datePickerStyle(.compact)
                .padding()
            HStack {
                Text("Wet or soiled?")
                Picker("Wet or soiled?", selection: $vm.wetOrSoiled) {
                    ForEach(NappyChange.WetOrSoiled.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
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
