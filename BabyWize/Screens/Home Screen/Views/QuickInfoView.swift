//
//  QuickInfoView.swift
//  BabyWize
//
//  Created by Noam Efergan on 21/10/2022.
//

import SwiftUI

// MARK: - QuickInfoView
struct QuickInfoView: View {
    let color: Color
    let backgroundColor: Color?
    let title: String
    let value: String
    let shouldShowInfo: Bool
    let leadingTo: InfoScreens

    init(color: Color,
         backgroundColor: Color? = nil,
         title: String,
         value: String,
         shouldShowInfo: Bool,
         leadingTo: InfoScreens) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.title = title
        self.value = value
        self.shouldShowInfo = shouldShowInfo
        self.leadingTo = leadingTo
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(.body, design: .rounded))
                    Spacer()
                    if shouldShowInfo {
                        NavigationLink(value: leadingTo) {
                            Image(systemName: "info.circle.fill")
                        }
                    }
                }
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .bold()
            }
            Spacer()
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal)
        .foregroundColor(color)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .foregroundColor(backgroundColor ?? color.opacity(0.2)))
    }
}

// MARK: - QuickInfoView_Previews
struct QuickInfoView_Previews: PreviewProvider {
    static var previews: some View {
        QuickInfoView(color: .init(hex: "#F05052"), title: "Last Feed", value: "170ml", shouldShowInfo: true,
                      leadingTo: .feed)
            .frame(width: 200)
    }
}
