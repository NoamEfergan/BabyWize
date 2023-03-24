//
//  BWLineMark.swift
//  BabyWize
//
//  Created by Noam Efergan on 24/03/2023.
//

import SwiftUI
import Charts

struct BWLineMark: ChartContent {
    let feed: Feed
    let amount: Double
    let series: String
    let foregroundGradient: AnyGradient
    private var date: String {
        feed.date.formatted(date: .omitted, time: .shortened)
    }

    var body: some ChartContent {
        LineMark(x: .value(Constants.timeTitle.rawValue, date),
                 y: .value(Constants.amountTitle.rawValue, amount),
                 series: .value(series, series))
            .foregroundStyle(foregroundGradient)
            .accessibilityHidden(true)
    }
}
