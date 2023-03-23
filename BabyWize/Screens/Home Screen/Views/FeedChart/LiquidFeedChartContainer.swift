//
//  LiquidFeedChartContainer.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/03/2023.
//

import SwiftUI
import Charts

// MARK: - LiquidFeedChartContainer
struct LiquidFeedChartContainer: View {
    private let markHelper = FeedMarkHelper()
    let data: [Feed]
    let plotWidth: CGFloat
    var title = "Liquids"
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.leading)
            ScrollView(.horizontal) {
                Chart(data.sorted(by: { $0.date < $1.date })) { feed in
                    markHelper.getLiquidsChart(for: feed)
                }
                .feedChartModifier(plotWidth: plotWidth)
            }
            .scrollIndicators(.visible)
        }
        .transition(.push(from: .bottom))
    }
}

// MARK: - LiquidFeedChartContainer_Previews
struct LiquidFeedChartContainer_Previews: PreviewProvider {
    static var previews: some View {
        LiquidFeedChartContainer(data: MockEntries.mockFeed, plotWidth: 250)
    }
}

// MARK: - MockEntries
enum MockEntries {
    static var mockFeed: [Feed] { [
        Feed(id: "1",
             date: Date.getRandomMockDate(),
             amount: 100,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.solid),
        Feed(id:"2",
             date: Date.getRandomMockDate(),
             amount: 120,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.solid),
        Feed(id: "3",
             date: Date.getRandomMockDate(),
             amount: 130,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid),
        Feed(id: "4",
             date: Date.getRandomMockDate(),
             amount: 120,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid),
        Feed(id: "5",
             date: Date.getRandomMockDate(),
             amount: 110,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid),
        Feed(id: "6",
             date: Date.getRandomMockDate(),
             amount: 150,
             note: nil,
             solidOrLiquid: Feed.SolidOrLiquid.liquid)
    ]
    .sorted(by: { $0.date < $1.date })
    }
}
