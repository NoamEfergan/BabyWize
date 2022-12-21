//
//  AddEntryView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import SwiftUI

// MARK: - AddEntryView
struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    @InjectedObject private var defaultManager: UserDefaultManager
    @ObservedObject var vm: AddEntryViewVM

    var body: some View {
        ScrollView {
            AccessiblePicker(title: "Entry type?", selection: $vm.entryType) {
                ForEach(EntryType.allCases.filter { $0 != .solidFeed }, id: \.self) {
                    Text($0.title)
                        .accessibilityLabel($0.title)
                        .accessibilityAddTraits(.isButton)
                }
            }
            switch vm.entryType {
            case .liquidFeed, .solidFeed:
                FeedEntryView(vm: vm.feedVM)
            case .sleep:
                SleepEntryView(vm: vm.sleepVM)
            case .nappy:
                NappyEntryView(vm: vm.nappyVM)
            }
            if !vm.errorText.isEmpty {
                Text(vm.errorText)
                    .foregroundColor(.red)
                    .accessibilityLabel("Error")
                    .accessibilityValue(vm.errorText)
            }
            Button(vm.buttonTitle) {
                vm.handleButtonTap()
            }
            .contentTransition(.interpolate)
            .animation(.easeInOut, value: vm.buttonTitle)
            .buttonStyle(.borderedProminent)
            .tint(AppColours.gradient)
        }
        .padding()
        .animation(.easeIn, value: vm.errorText)
        .animation(.easeInOut, value: vm.entryType)
        .onChange(of: vm.entryType) { _ in
            vm.errorText = ""
            vm.buttonTitle = vm.getButtonTitle()
        }
        .onChange(of: defaultManager.hasTimerRunning) { _ in
            vm.buttonTitle = vm.getButtonTitle()
        }
        .onReceive(vm.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                vm.shouldDismiss = false
                dismiss()
            }
        }
    }
}

// MARK: - AddEntryView_Previews
struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView(vm: .init())
    }
}
