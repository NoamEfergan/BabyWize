//
//  SleepEntryView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

struct SleepEntryView: View {
    @EnvironmentObject private var vm: NewEntryViewModel
    var body: some View {
        VStack {
            DatePicker("From", selection: $vm.startDate)
                .datePickerStyle(.compact)
            DatePicker("Until", selection: $vm.endDate)
                .datePickerStyle(.compact)
        }
        .padding()
    }
}

struct SleepEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SleepEntryView()
            .environmentObject(NewEntryViewModel())
    }
}
