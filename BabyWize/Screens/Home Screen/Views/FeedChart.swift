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
                            BarMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                    y: .value("Amount", feed.amount))
                                .foregroundStyle(Color.clear)
                                .annotation(position: .top, alignment: .center) {
                                    Text(feed.note ?? "")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                            PointMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                      y: .value("Amount", feed.amount))
                                .foregroundStyle(Color.orange.gradient)
                            LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                     y: .value("Amount", feed.amount),
                                     series: .value("Solids", "Solids"))
                                .foregroundStyle(Color.orange.gradient)

                        } else {
                            // This is a workaround because annotations don't work on line marks
                            let unit = feed.amount.convertFromML()
                            BarMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                    y: .value("Amount", unit))
                                .foregroundStyle(Color.clear)
                                .annotation(position: .top, alignment: .center) {
                                    Text(feed.note ?? "")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                            PointMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                      y: .value("Amount", unit))
                                .foregroundStyle(Color.blue.gradient)
                            LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                     y: .value("Amount", unit),
                                     series: .value("Liquids", "Liquids"))
                                .foregroundStyle(Color.blue.gradient)
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
