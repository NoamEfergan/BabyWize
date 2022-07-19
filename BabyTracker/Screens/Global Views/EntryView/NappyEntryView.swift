//
//  NappyEntryView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

struct NappyEntryView: View {
    @EnvironmentObject private var vm: EntryViewModel
    var body: some View {
        DatePicker("When", selection: $vm.changeDate)
            .datePickerStyle(.compact)
            .padding()
    }
}

struct NappyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NappyEntryView()
            .environmentObject(EntryViewModel())
    }
}
