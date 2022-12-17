//
//  SleepEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

// MARK: - SleepEntryView
struct SleepEntryView: View {
    @ObservedObject var vm: SleepEntryViewModel
    let pickerTitle = "Live or old?"
    var body: some View {
        VStack(alignment: .leading) {
            AccessibleDatePicker(label: "When", value: $vm.sleepDate)
            AccessibleDatePicker(label: "From", value: $vm.startDate)
            AccessibleDatePicker(label: "Until", value: $vm.endDate)
        }
        .padding()
    }
}

// MARK: - SleepEntryView_Previews
struct SleepEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SleepEntryView(vm: .init())
    }
}
