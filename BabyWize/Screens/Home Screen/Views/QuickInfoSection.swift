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
    let columns = [
        GridItem(.adaptive(minimum: 160)),
        GridItem(.adaptive(minimum: 160)),
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: columns, spacing: 10) {
                QuickInfoView(color: .init(hex: "#A68AFA"),
                              title: "Last Feed",
                              value: dataManager.feedData.last?.amount.roundDecimalPoint().feedDisplayableAmount()
                                  ?? "None recorded")
                QuickInfoView(color: .init(hex: "#E98F32"),
                              title: "Last Nappy change",
                              value: dataManager.nappyData.last?.dateTime.formatted() ?? "None recorded")
                QuickInfoView(color: .init(hex: "#1DB8D2"),
                              title: "Last Sleep",
                              value: dataManager.sleepData.last?.duration.convertToTimeInterval()
                                  .displayableString ?? "None recorded")
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
