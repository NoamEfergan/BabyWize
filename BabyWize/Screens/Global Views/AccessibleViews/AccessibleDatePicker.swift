//
//  AccessibleDatePicker.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import SwiftUI

// MARK: - AccessibleDatePicker
struct AccessibleDatePicker: View {
    @Environment(\.dynamicTypeSize) var typeSize
    let label: String
    @Binding var value: Date

    var body: some View {
        Group {
            switch typeSize {
            case .xSmall, .small, .medium, .large, .xLarge :

                DatePicker(label, selection: $value)
                    .datePickerStyle(.compact)
            default:
                VStack(alignment: .leading) {
                    Text(label)
                    DatePicker("", selection: $value)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .multilineTextAlignment(.leading)
                }
                .font(.system(.body, design: .rounded))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(value.formatted())
    }
}

// MARK: - AccessibleDatePicker_Previews
struct AccessibleDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        AccessibleDatePicker(label: "Pick a date", value: .constant(.distantPast))
    }
}
