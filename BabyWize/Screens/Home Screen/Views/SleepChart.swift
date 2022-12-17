//
//  SleepChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 01/11/2022.
//

import Charts
import SwiftUI

// MARK: - SleepChart
struct SleepChart: View {
    @Environment(\.dynamicTypeSize) var typeSize
    // Adding additional sizing according to the typesize
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

    var sleepData: [Sleep]
    var showTitle = true
    var body: some View {
        VStack(alignment: .leading) {
            if showTitle {
                Text(sleepInfoTitle)
                    .font(.system(.title, design: .rounded))
                    .padding(.leading)
            }
            if sleepData.isEmpty {
                PlaceholderChart(type: .sleep)
            } else {
                ScrollView(.horizontal) {
                    Chart(sleepData.sorted(by: { $0.date < $1.date })) { sleep in
                        let amountValue = sleep.getDisplayableString()
                        BarMark(x: .value("Time", sleep.date.getTwoLinedString()),
                                y: .value("Amount", sleep.getTimeInterval()))
                            .annotation(position: .top, alignment: .center) {
                                Text("\(amountValue)")
                                    .font(.system(.body, design: .rounded))
                            }
                            .foregroundStyle(Color.red.gradient)
                            .accessibilityLabel(sleep.date.formatted())
                            .accessibilityValue(sleep.getDisplayableString()
                                .replacingOccurrences(of: "\n", with: " and "))
                    }
                    .chartPlotStyle(content: { plotArea in
                        plotArea.frame(width: CGFloat(sleepData.count) * (120 + sizeModifier))
                    })
                    .chartYAxis(.hidden)
                    .frame(minHeight: 200)
                    .frame(maxWidth: .greatestFiniteMagnitude)
                    .padding()
                }
            }
        }
    }

    private var sleepInfoTitle: String {
        if sleepData.isEmpty {
            return "Sleep info"
        } else {
            let feedCount = sleepData.count >= 3 ? 3 : sleepData.count
            return "Sleep info (last \(feedCount))"
        }
    }
}

// MARK: - SleepChart_Previews
struct SleepChart_Previews: PreviewProvider {
    static var previews: some View {
        SleepChart(sleepData: PlaceholderChart.MockData.getMockSleep())
    }
}
