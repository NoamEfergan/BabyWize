//
//  QuickInfoSection.swift
//  BabyWize
//
//  Created by Noam Efergan on 21/10/2022.
//

import SwiftUI

// MARK: - QuickInfoSection
struct QuickInfoSection: View {
    @InjectedObject private var dataManager: BabyDataManager
    @InjectedObject private var unitManager: UserDefaultManager
    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        switch typeSize {
        case .xSmall, .small, .medium, .large:
            VStack {
                HStack {
                    QuickInfoView(color: .init(hex: "#F05052"),
                                  title: "Last Feed",
                                  value: dataManager.getLast(for: .liquidFeed),
                                  shouldShowInfo: !dataManager.feedData.isEmpty,
                                  leadingTo: .feed)
                    QuickInfoView(color: .init(hex: "#5354EC"),
                                  title: "Last Sleep",
                                  value: dataManager.getLast(for: .sleep),
                                  shouldShowInfo: !dataManager.sleepData.isEmpty,
                                  leadingTo: .sleep)
                }
                QuickInfoView(color: .init(hex: "#F0A24E"),
                              backgroundColor: .init(hex: "#F6DDC5"),
                              title: "Last Nappy Change",
                              value: dataManager.getLast(for: .nappy),
                              shouldShowInfo: !dataManager.nappyData.isEmpty,
                              leadingTo: .detailInputNappy)
            }
        default:
            VStack {
                QuickInfoView(color: .init(hex: "#F05052"),
                              title: "Last Feed",
                              value: dataManager.getLast(for: .liquidFeed),
                              shouldShowInfo: !dataManager.feedData.isEmpty,
                              leadingTo: .feed)
                QuickInfoView(color: .init(hex: "#5354EC"),
                              title: "Last Sleep",
                              value: dataManager.getLast(for: .sleep),
                              shouldShowInfo: !dataManager.sleepData.isEmpty,
                              leadingTo: .sleep)
                QuickInfoView(color: .init(hex: "#F0A24E"),
                              backgroundColor: .init(hex: "#F6DDC5"),
                              title: "Last Nappy Change",
                              value: dataManager.getLast(for: .nappy),
                              shouldShowInfo: false,
                              leadingTo: .none)
            }
        }
    }
}

// MARK: - QuickInfoSection_Previews
struct QuickInfoSection_Previews: PreviewProvider {
    static var previews: some View {
        QuickInfoSection()
    }
}
