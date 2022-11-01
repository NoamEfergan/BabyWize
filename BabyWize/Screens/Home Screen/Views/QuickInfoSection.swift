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

    private var feedValue: String { dataManager.feedData.last?.amount.roundDecimalPoint().feedDisplayableAmount()
        ?? notAvailable
    }

    private var sleepValue: String { dataManager.sleepData.last?.duration.convertToTimeInterval()
        .displayableString ?? notAvailable
    }

    private var nappyValue: String {
        guard let lastNappy = dataManager.nappyData.last else {
            return notAvailable
        }
        return "\(lastNappy.dateTime.formatted(date: .omitted, time: .shortened)), \(lastNappy.wetOrSoiled.rawValue) "
    }

    var body: some View {
        VStack {
            HStack {
                QuickInfoView(color: .init(hex: "#F05052"),
                              title: "Last Feed",
                              value: feedValue,
                              shouldShowInfo: !dataManager.feedData.isEmpty,
                              leadingTo: .feed)
                QuickInfoView(color: .init(hex: "#5354EC"),
                              title: "Last Sleep",
                              value: sleepValue,
                              shouldShowInfo: !dataManager.sleepData.isEmpty,
                              leadingTo: .sleep)
            }
            QuickInfoView(color: .init(hex: "#F0A24E"),
                          backgroundColor: .init(hex: "#F6DDC5"),
                          title: "Last Nappy change",
                          value: nappyValue,
                          shouldShowInfo: false,
                          leadingTo: .none)
        }
    }
}

// MARK: - QuickInfoSection_Previews
struct QuickInfoSection_Previews: PreviewProvider {
    static var previews: some View {
        QuickInfoSection()
    }
}
