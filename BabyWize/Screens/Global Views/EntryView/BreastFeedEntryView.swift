//
//  BreastFeedEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 02/01/2023.
//

import SwiftUI

// MARK: - BreastFeedEntryView
struct BreastFeedEntryView: View {
    @ObservedObject var vm: BreastFeedEntryViewModel
    @Inject private var defaultManager: UserDefaultManager
    @State private var startDate: Date? = nil
    var body: some View {
        VStack(alignment: vm.selectedLiveOrOld == .Old ? .leading : .center) {
            AccessiblePicker(title: "Live or old?",
                             selection: $vm.selectedLiveOrOld) {
                ForEach(BreastFeedEntryViewModel.LiveOrOld.allCases, id: \.self) {
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
            guard let start = defaultManager.feedStartDate else {
                return
            }
            startDate = start
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.feedTimerEnd)) { _ in
            startDate = nil
        }
    }
}

// MARK: - BreastFeedEntryView_Previews
struct BreastFeedEntryView_Previews: PreviewProvider {
    static var previews: some View {
        BreastFeedEntryView(vm: .init())
    }
}
