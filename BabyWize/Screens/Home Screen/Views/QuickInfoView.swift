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
    let leadingTo: Screens

    init(color: Color,
         backgroundColor: Color? = nil,
         title: String,
         value: String,
         shouldShowInfo: Bool,
         leadingTo: Screens) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.title = title
        self.value = value
        self.shouldShowInfo = shouldShowInfo
        self.leadingTo = leadingTo
    }

    var spacing: Double {
        value.contains("\n") ? 0 : 10
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: spacing) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(.system(.body, design: .rounded))
                    Spacer()
                    if shouldShowInfo {
                        NavigationLink(value: leadingTo) {
                            Image(systemName: "info.circle.fill")
                        }
                    }
                }
                .padding(.top)
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .bold()
                Spacer()
            }
        }
        .animation(.easeInOut, value: value)
        .multilineTextAlignment(.leading)
        .padding(.horizontal)
        .foregroundColor(color)
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .foregroundColor(backgroundColor ?? color.opacity(0.2)))
    }
}

// MARK: - QuickInfoView_Previews
struct QuickInfoView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            QuickInfoView(color: .init(hex: "#F05052"), title: "Last sleep", value: "5 Hours,\n40 mins",
                          shouldShowInfo: true,
                          leadingTo: .feed)
                .frame(width: 200)

            QuickInfoView(color: .init(hex: "#F05052"), title: "Last Feed", value: "170ml", shouldShowInfo: true,
                          leadingTo: .feed)
                .frame(width: 200)
        }
        .frame(height: 200)
    }
}
