//
//  BWChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 24/03/2023.
//

import SwiftUI
import Charts

struct BWChart: ChartContent {
    let feed: Feed
    let series: String
    let foregroundGradient: AnyGradient
    private var unit: Double { feed.amount.roundDecimalPoint() }
    var body: some ChartContent {
        BWBarMark(feed: feed, amount: unit)
        BWPointMark(feed: feed, amount: unit, foregroundGradient: foregroundGradient)
        BWLineMark(feed: feed, amount: unit, series: series, foregroundGradient:foregroundGradient)
    }
}
