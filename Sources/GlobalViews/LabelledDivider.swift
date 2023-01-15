//
//  LabelledDivider.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/11/2022.
//

import SwiftUI

public struct LabelledDivider: View {
    let label: String?
    let horizontalPadding: CGFloat
    let color: Color

    public init(label: String? = nil, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    public var body: some View {
        HStack {
            if let label {
                line
                Text(label).foregroundColor(color)
                line
            } else {
                line
            }
        }
    }

    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}
