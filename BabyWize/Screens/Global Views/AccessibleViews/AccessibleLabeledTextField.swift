//
//  AccessibleLabeledTextField.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import SwiftUI

// MARK: - AccessibleLabeledTextField
struct AccessibleLabeledTextField: View {
    @Environment(\.dynamicTypeSize) var typeSize
    let label: String
    let hint: String
    @Binding var value: String

    var body: some View {
        Group {
            switch typeSize {
            case .xSmall, .small, .medium, .large, .xLarge :
                LabeledContent(label) {
                    TextField(hint, text: $value)
                        .textFieldStyle(.roundedBorder)
                }
            default:
                VStack(alignment: .leading) {
                    Text(label)
                    TextField(hint, text: $value)
                        .multilineTextAlignment(.leading)
                        .textFieldStyle(.roundedBorder)
                }
                .font(.system(.body, design: .rounded))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

// MARK: - AccessibleLabeledTextField_Previews
struct AccessibleLabeledTextField_Previews: PreviewProvider {
    static var previews: some View {
        AccessibleLabeledTextField(label: "Enter something", hint: "Please enter", value: .constant(""))
    }
}
