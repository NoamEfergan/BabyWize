//
//  AccessiblePicker.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/12/2022.
//

import SwiftUI

// MARK: - AccessiblePicker
struct AccessiblePicker<Selection: Hashable>: View {
    @Environment(\.dynamicTypeSize) var typeSize
    let title: String
    @Binding var selection: Selection
    let data: [String]

    var body: some View {
        switch typeSize {
        case .xSmall, .small, .medium, .large, .xLarge , .xxLarge:
            HStack {
                picker
                    .pickerStyle(.segmented)
            }
        default:
            VStack {
                Text(title)
                picker
                    .pickerStyle(.automatic)
            }
        }
    }

    @ViewBuilder
    private var picker: some View {
        Picker(title, selection: $selection) {
            ForEach(data, id: \.self) {
                Text($0.capitalized)
                    .accessibilityLabel($0)
                    .accessibilityAddTraits(.isButton)
            }
        }
    }
}

// MARK: - AccessiblePicker_Previews
struct AccessiblePicker_Previews: PreviewProvider {
    static var previews: some View {
        AccessiblePicker(title: "Test", selection: .constant("Test"), data: ["test", "test2"])
    }
}
