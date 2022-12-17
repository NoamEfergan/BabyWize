//
//  NappyEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

// MARK: - NappyEntryView
struct NappyEntryView: View {
    @ObservedObject var vm: NappyEntryViewModel

    var body: some View {
        VStack {
            AccessibleDatePicker(label: "When", value: $vm.changeDate)
                .padding()
            HStack {
                let title = "Wet or soiled?"
                Text(title)
                AccessiblePicker(title: title,
                                 selection: $vm.wetOrSoiled,
                                 data: NappyChange.WetOrSoiled.allCases.compactMap { $0.rawValue })
            }
        }
    }
}

// MARK: - NappyEntryView_Previews
struct NappyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NappyEntryView(vm: .init())
    }
}
