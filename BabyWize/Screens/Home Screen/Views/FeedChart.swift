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
    let feedData: [Feed]
    var showTitle: Bool = true
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
                Chart(feedData) { feed in
                    // This is a workaround because annotations don't work on line marks
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
                        .foregroundStyle(Color.blue.gradient)
                    LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                             y: .value("Amount", feed.amount))
                        .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .frame(width: UIScreen.main.bounds.width)
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
