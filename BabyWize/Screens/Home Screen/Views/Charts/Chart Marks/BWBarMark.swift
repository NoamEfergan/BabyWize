//
//  BWBarMark.swift
//  BabyWize
//
//  Created by Noam Efergan on 24/03/2023.
//

import SwiftUI
import Charts

struct BWBarMark: ChartContent {
    let feed: Feed
    let amount: Double
    private var date: String {
        feed.date.formatted(date: .omitted, time: .shortened)
    }

    var body: some ChartContent {
        BarMark(x: .value(Constants.timeTitle.rawValue, date),
                y: .value(Constants.amountTitle.rawValue, amount))
            .foregroundStyle(Color.clear)
            .annotation(position: .top, alignment: .center) {
                Text(feed.note ?? "")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityHidden(true)
    }
}
