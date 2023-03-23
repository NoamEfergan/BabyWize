//
//  FeedMarkHelper.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/03/2023.
//

import Foundation
import Charts
import SwiftUI

struct FeedMarkHelper {
    private let timeTitle = "Time"
    private let amountTitle = "Amount"

    // MARK: - Charts methods

    @ChartContentBuilder
    func getLiquidsChart(for feed: Feed) -> some ChartContent {
        let unit = feed.amount.roundDecimalPoint()
        getBarMark(for: feed, amount: unit)
            .foregroundStyle(Color.clear)
            .annotation(position: .top, alignment: .center) {
                Text(feed.note ?? "")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityHidden(true)

        getPointMark(for: feed, amount: unit)
            .foregroundStyle(Color.blue.gradient)
            .annotation(position: .bottom, alignment: .center) {
                Text(feed.amount.liquidFeedDisplayableAmount())
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityLabel(feed.date.formatted())
            .accessibilityValue("\(feed.amount.liquidFeedDisplayableAmount()), \(feed.solidOrLiquid.title)")
        getLineMark(for: feed, amount: unit, series: "Liquids")
            .foregroundStyle(Color.blue.gradient)
            .accessibilityHidden(true)
    }

    @ChartContentBuilder
    private func getBarMark(for feed: Feed, amount: Double) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        BarMark(x: .value(timeTitle, date),
                y: .value(amountTitle, amount))
    }

    @ChartContentBuilder
    private func getPointMark(for feed: Feed, amount: Double) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        PointMark(x: .value(timeTitle, date),
                  y: .value(amountTitle, amount))
    }

    @ChartContentBuilder
    private func getLineMark(for feed: Feed, amount: Double, series: String) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        LineMark(x: .value(timeTitle, date),
                 y: .value(amountTitle, amount),
                 series: .value(series, series))
    }
}
