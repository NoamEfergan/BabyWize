////
////  BreastFeedView.swift
////  BabyWize
////
////  Created by Noam Efergan on 02/01/2023.
////
//
// import SwiftUI
//
// struct BreastFeedView: View {
//    @ObservedObject var vm: FeedEntryViewModel
//    @Inject private var defaultManager: UserDefaultManager
//    @State private var startDate: Date? = nil
//    var body: some View {
//        VStack(alignment: vm.selectedLiveOrOld == .Old ? .leading : .center) {
//            AccessiblePicker(title: "Live or old?",
//                             selection: $vm.selectedLiveOrOld) {
//                ForEach(FeedEntryViewModel.BreastFeedLiveOrOld.allCases, id: \.self) {
//                    Text($0.rawValue.capitalized)
//                        .accessibilityLabel($0.rawValue)
//                        .accessibilityAddTraits(.isButton)
//                }
//            }
//            switch vm.selectedLiveOrOld {
//            case .Old:
//                AccessibleDatePicker(label: "When", value: $vm.sleepDate)
//                AccessibleDatePicker(label: "From", value: $vm.startDate)
//                AccessibleDatePicker(label: "Until", value: $vm.endDate)
//            case .Live:
//                if let startDate {
//                    TimerView(startDate: startDate)
//                }
//            }
//        }
//        .padding()
//        .animation(.easeInOut, value: vm.selectedLiveOrOld)
//        .onAppear {
//            // TODO: Date
//            guard let start = defaultManager.sleepStartDate else {
//                return
//            }
//            startDate = start
//        }
//        // TODO: Date and notifications
//        .onReceive(NotificationCenter.default.publisher(for: NSNotification.sleepTimerEnd)) { _ in
//            startDate = nil
//        }
//    }
// }
//
// struct BreastFeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        BreastFeedView(vm: .init())
//    }
// }
