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
    @Inject private var defaultManager: UserDefaultManager
    @State private var timeSinceStart: TimeInterval = 0.0
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                AccessibleDatePicker(label: "When", value: $vm.sleepDate)
                AccessibleDatePicker(label: "From", value: $vm.startDate)
                AccessibleDatePicker(label: "Until", value: $vm.endDate)
            case .Live:
                if timeSinceStart > 0.0 {
                    Text(timeSinceStart.hourMinuteSecondMS)
                        .onReceive(timer) { _ in
                            timeSinceStart += 1
                        }
                        .contentTransition(.interpolate)
                }
            }
        }
        .onAppear {
            guard let start = defaultManager.sleepStartDate else {
                return
            }
            timeSinceStart = Date().timeIntervalSince(start)
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
