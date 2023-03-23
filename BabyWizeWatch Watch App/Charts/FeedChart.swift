//
//  FeedChart.swift
//  BabyWizeWatch Watch App
//
//  Created by Noam Efergan on 22/03/2023.
//

import SwiftUI
import Charts

// MARK: - FeedChart
struct FeedChart: View {
    @Environment(\.dynamicTypeSize) var typeSize
    @State private var feedData: [Feed] = []
    @State private var didAnimateFeedAlready = false
    var body: some View {
        feedChart
            .chartPlotStyle { plotArea in
                plotArea.frame(width: plotWidth)
            }
            .frame(maxHeight: .greatestFiniteMagnitude)
            .frame(maxWidth: .greatestFiniteMagnitude)
            .padding()
    }

    @ViewBuilder
    private var feedChart: some View {
        Chart(feedData.getUpTo(limit: 3)) { feed in
            LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                     y: .value("Amount", feed.amount))
                .foregroundStyle(Color.blue.gradient)
        }
        .onAppear {
            if !didAnimateFeedAlready {
                feedData.removeAll()
                for (index, item) in mockFeed.enumerated() {
                    withAnimation(.easeIn(duration: 0.2).delay(Double(index) * 0.1)) {
                        feedData.append(item)
                    }
                }
                didAnimateFeedAlready = true
            }
        }
    }
}

// MARK: - Computed properties

private extension FeedChart {
    var plotWidth: CGFloat {
        170 + sizeModifier
    }

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
}

// MARK: - Dummy Data

private extension FeedChart {
    var mockFeed: [Feed] { [
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

// MARK: - FeedChart_Previews
struct FeedChart_Previews: PreviewProvider {
    static var previews: some View {
        FeedChart()
    }
}
