//
//  AccessiblePicker.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/12/2022.
//

import SwiftUI

// MARK: - AccessiblePicker
struct AccessiblePicker<Selection: Hashable, Content: View>: View {
    @Environment(\.dynamicTypeSize) var typeSize
    let title: String
    @Binding var selection: Selection
    let content: () -> Content

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
        Picker(title, selection: $selection, content: content)
            .font(.system(.body,design: .rounded))
    }
}

// MARK: - AccessiblePicker_Previews
struct AccessiblePicker_Previews: PreviewProvider {
    static var previews: some View {
        AccessiblePicker(title: "Test", selection: .constant("Test")) {
            ForEach(["Test, Test2"], id: \.self) {
                Text($0.capitalized)
                    .accessibilityLabel($0)
                    .accessibilityAddTraits(.isButton)
            }
        }
    }
}
