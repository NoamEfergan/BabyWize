//
//  ChartContainer.swift
//  BabyWize
//
//  Created by Noam Efergan on 24/03/2023.
//

import SwiftUI
import Charts

// MARK: - ChartContainer
struct ChartContainer: View {
    let title: String
    let data: [Feed]
    let plotWidth: CGFloat
    let foregroundGradient: AnyGradient
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.leading)
            ScrollView(.horizontal) {
                Chart(data.sorted(by: { $0.date < $1.date })) { feed in
                    BWChart(feed: feed, series: title, foregroundGradient: foregroundGradient)
                }
                .feedChartModifier(plotWidth: plotWidth)
            }
            .scrollIndicators(.visible)
        }
        .transition(.push(from: .top))
        .frame(minHeight: 200) // TODO: Maybe remove this
    }
}

// MARK: - ChartContainer_Previews
struct ChartContainer_Previews: PreviewProvider {
    static var previews: some View {
        ChartContainer(title: "Solids", data: MockEntries.mockFeed.filter(\.isSolids), plotWidth: 250,
                       foregroundGradient: Color.orange.gradient)
    }
}
