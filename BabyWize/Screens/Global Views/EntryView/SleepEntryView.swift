//
//  SleepEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI
import Models
import Managers

// MARK: - SleepEntryView
struct SleepEntryView: View {
    @ObservedObject var vm: SleepEntryViewModel
    @Inject private var defaultManager: UserDefaultManager
    @State private var startDate: Date? = nil
    var body: some View {
        VStack(alignment: vm.selectedLiveOrOld == .Old ? .leading : .center) {
            AccessiblePicker(title: "Live or old?",
                             selection: $vm.selectedLiveOrOld) {
                ForEach(SleepEntryViewModel.LiveOrOld.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                        .accessibilityLabel($0.rawValue)
                        .accessibilityAddTraits(.isButton)
                }
            }
            switch vm.selectedLiveOrOld {
            case .Old:
                AccessibleDatePicker(label: "From", value: $vm.startDate)
                AccessibleDatePicker(label: "Until", value: $vm.endDate)
            case .Live:
                if let startDate {
                    TimerView(startDate: startDate)
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: vm.selectedLiveOrOld)
        .onAppear {
            guard let start = defaultManager.sleepStartDate else {
                return
            }
            startDate = start
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.sleepTimerEnd)) { _ in
            startDate = nil
        }
    }
}

// MARK: - SleepEntryView_Previews
struct SleepEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SleepEntryView(vm: .init())
    }
}
