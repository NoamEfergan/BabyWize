//
//  BWPointMark.swift
//  BabyWize
//
//  Created by Noam Efergan on 24/03/2023.
//

import SwiftUI
import Charts

struct BWPointMark: ChartContent {
    let feed: Feed
    let amount: Double
    let foregroundGradient: AnyGradient
    private var date: String {
        feed.date.formatted(date: .omitted, time: .shortened)
    }

    var body: some ChartContent {
        PointMark(x: .value(Constants.timeTitle.rawValue, date),
                  y: .value(Constants.amountTitle.rawValue, amount))
            .foregroundStyle(foregroundGradient)
            .annotation(position: .bottom, alignment: .center) {
                Text(amount.solidFeedDisplayableAmount())
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityLabel(feed.date.formatted())
            .accessibilityValue("\(feed.amount.solidFeedDisplayableAmount()), \(feed.solidOrLiquid.title)")
    }
}
