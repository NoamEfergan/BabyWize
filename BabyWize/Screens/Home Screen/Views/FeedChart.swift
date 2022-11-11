//
//  FeedChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 01/11/2022.
//

import Charts
import SwiftUI

// MARK: - FeedChart
struct FeedChart: View {
    var feedData: [Feed]
    var showTitle = true
    
    private let timeTitle = "Time"
    private let amountTitle = "Amount"
    @Environment(\.dynamicTypeSize) var typeSize
    var sizeModifier: Double {
        switch typeSize {
        case .xSmall, .small, .medium , .large, .xLarge, .xxLarge:
            return 0
        case .xxxLarge:
            return 55
        case .accessibility1:
            return 80
        case .accessibility2:
            return 120
        case .accessibility3:
            return 175
        case .accessibility4:
            return 220
        case .accessibility5:
            return 300
        default:
            return 1
        }
    }


    var body: some View {
        VStack(alignment: .leading) {
            if showTitle {
                Text(feedInfoTitle)
                    .font(.system(.title, design: .rounded))
                    .padding(.leading)
            }
            if feedData.isEmpty {
                PlaceholderChart(type: .feed)
            } else {
                ScrollView(.horizontal) {
                    Chart(feedData.sorted(by: { $0.date < $1.date })) { feed in
                        if feed.solidOrLiquid == .solid {
                            getSolidsChart(for: feed)
                        } else {
                            getLiquidsChart(for: feed)
                        }
                    }
                    .chartPlotStyle(content: { plotArea in
                        plotArea.frame(width: CGFloat(feedData.count) * (80 + sizeModifier))
                    })
                    .frame(maxHeight: .greatestFiniteMagnitude)
                    .frame(minWidth: UIScreen().bounds.width)
                    .frame(maxWidth: .greatestFiniteMagnitude)
                    .padding()
                }
            }
        }
    }

    @ChartContentBuilder
    private func getLiquidsChart(for feed: Feed) -> some ChartContent {
        let unit = feed.amount.convertFromML()
        getBarMark(for: feed, amount: unit)
            .foregroundStyle(Color.clear)
            .annotation(position: .top, alignment: .center) {
                Text(feed.note ?? "")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }


        getPointMark(for: feed, amount: unit)
            .foregroundStyle(Color.blue.gradient)
            .annotation(position: .bottom, alignment: .center) {
                Text(feed.amount.roundDecimalPoint().description)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        getLineMark(for: feed, amount: unit, series: "Liquids")
            .foregroundStyle(Color.blue.gradient)
    }

    @ChartContentBuilder
    private func getSolidsChart(for feed: Feed) -> some ChartContent {
        let amount = feed.amount
        getBarMark(for: feed, amount: amount)
            .foregroundStyle(Color.clear)
            .annotation(position: .top, alignment: .center) {
                Text(feed.note ?? "")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

        getPointMark(for: feed, amount: amount)
            .foregroundStyle(Color.orange.gradient)
            .annotation(position: .bottom, alignment: .center) {
                Text(amount.description)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        getLineMark(for: feed, amount: amount, series: "Solids")
            .foregroundStyle(Color.orange.gradient)
    }

    private func getBarMark(for feed: Feed, amount: Double) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        return BarMark(x: .value(timeTitle, date),
                       y: .value(amountTitle, amount))
    }

    private func getPointMark(for feed: Feed, amount: Double) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        return PointMark(x: .value(timeTitle, date),
                         y: .value(amountTitle, amount))
    }

    private func getLineMark(for feed: Feed, amount: Double, series: String) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        return LineMark(x: .value(timeTitle, date),
                        y: .value(amountTitle, amount),
                        series: .value(series, series))
    }

    private var feedInfoTitle: String {
        if feedData.isEmpty {
            return "Feed info"
        } else {
            let feedCount = feedData.count >= 6 ? 6 : feedData.count
            return "Feed info (last \(feedCount))"
        }
    }
}

// MARK: - FeedChart_Previews
struct FeedChart_Previews: PreviewProvider {
    static var previews: some View {
        FeedChart(feedData: PlaceholderChart.MockData.mockFeed)
    }
}
