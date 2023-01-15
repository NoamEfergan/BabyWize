//
//  CountdownTimeComponent.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/12/2022.
//

import SwiftUI

// MARK: - CountdownTimeComponent
public struct CountdownTimeComponent: View {
    let title: String
    let showingTitles: Bool
    @Binding var counterValue: String

    public init(title: String, showingTitles: Bool, counterValue: Binding<String>) {
        self.title = title
        self.showingTitles = showingTitles
        _counterValue = counterValue
    }

    public var body: some View {
        VStack(spacing: 5) {
            Text(counterValue)
                .font(.system(.title, design: .rounded))
                .padding(10)
                .background(.secondary.opacity(0.2))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.4) ,lineWidth: 1))
                .monospacedDigit()
                .animation(.easeInOut, value: counterValue)
                .transition(.opacity)

            if showingTitles {
                Text(title)
                    .font(.system(.footnote, design: .rounded))
            }
        }
    }
}

// MARK: - CountdownTimeComponent_Previews
struct CountdownTimeComponent_Previews: PreviewProvider {
    static var previews: some View {
        CountdownTimeComponent(title: "hours".lowercased(),showingTitles: true, counterValue: .constant("23"))
        CountdownTimeComponent(title: "hours".lowercased(),showingTitles: false, counterValue: .constant("23"))
    }
}
