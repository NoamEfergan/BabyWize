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
    let notAvailable = "N/A"

    var body: some View {
        VStack {
            HStack {
                QuickInfoView(color: .init(hex: "#F05052"),
                              title: "Last Feed",
                              value: dataManager.feedData.last?.amount.roundDecimalPoint().feedDisplayableAmount()
                                  ?? notAvailable,
                              shouldShowInfo: !dataManager.feedData.isEmpty,
                              leadingTo: .feed)
                QuickInfoView(color: .init(hex: "#EAA251"),
                              title: "Last Nappy change",
                              value: dataManager.nappyData.last?.dateTime.formatted() ?? notAvailable,
                              shouldShowInfo: false,
                              leadingTo: .none)
            }
            QuickInfoView(color: .init(hex: "#5354EC"),
                          title: "Last Sleep",
                          value: dataManager.sleepData.last?.duration.convertToTimeInterval()
                              .displayableString ?? notAvailable,
                          shouldShowInfo: !dataManager.sleepData.isEmpty,
                          leadingTo: .sleep)
        }
    }
}

// MARK: - QuickInfoSection_Previews

struct QuickInfoSection_Previews: PreviewProvider {
    static var previews: some View {
        QuickInfoSection()
    }
}
