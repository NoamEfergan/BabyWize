//
//  AccessibleLabeledContent.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/11/2022.
//

import SwiftUI

// MARK: - AccessibleLabeledContent
public struct AccessibleLabeledContent: View {
    @Environment(\.dynamicTypeSize) var typeSize
    let label: String
    let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    public var body: some View {
        Group {
            switch typeSize {
            case .xSmall, .small, .medium, .large, .xLarge :
                LabeledContent(label, value: value)
            default:
                VStack(alignment: .leading, spacing: 0) {
                    Text(label)
                    Spacer()
                    Text(value)
                        .foregroundColor(.secondary)
                        .allowsTightening(false)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .font(.system(.body, design: .rounded))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

// MARK: - VerticalLabeledContent_Previews
struct VerticalLabeledContent_Previews: PreviewProvider {
    static var previews: some View {
        AccessibleLabeledContent(label: "Label", value: Date().formatted())
    }
}
