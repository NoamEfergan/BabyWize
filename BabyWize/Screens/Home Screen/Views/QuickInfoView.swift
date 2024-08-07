//
//  QuickInfoView.swift
//  BabyWize
//
//  Created by Noam Efergan on 21/10/2022.
//

import SwiftUI

// MARK: - QuickInfoView
struct QuickInfoView: View {
    @EnvironmentObject private var navigationVM: NavigationViewModel
    let color: Color
    var backgroundColor: Color? = nil
    let title: String
    @Binding var value: String
    let shouldShowInfo: Bool
    let leadingTo: Screens

    var spacing: Double {
        value.contains("\n") ? 0 : 10
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: spacing) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(.system(.body, design: .rounded))
                        .accessibilityHidden(true)
                    Spacer()
                    if shouldShowInfo {
                        NavigationLink(value: leadingTo) {
                            Image(systemName: "info.circle.fill")
                        }
                        .accessibilityLabel("Show \(title) info")
                        .accessibilityRemoveTraits(.isImage)
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.top)
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .accessibilityLabel(title)
                    .accessibilityValue(value)
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
            .foregroundColor(backgroundColor ?? color.opacity(0.2))
            .onTapGesture {
                if shouldShowInfo {
                    navigationVM.path.append(leadingTo)
                }
            })
    }
}

// MARK: - QuickInfoView_Previews
struct QuickInfoView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            QuickInfoView(color: .init(hex: "#F05052"),
                          title: "Last sleep",
                          value: .constant("5 Hours,\n40 mins"),
                          shouldShowInfo: true,
                          leadingTo: .feed)
                .frame(width: 200)

            QuickInfoView(color: .init(hex: "#F05052"),
                          title: "Last Feed",
                          value: .constant("170ml"), shouldShowInfo: true,
                          leadingTo: .feed)
                .frame(width: 200)
        }
        .frame(height: 200)
    }
}
