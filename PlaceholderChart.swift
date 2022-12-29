//
//  PlaceholderChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 30/10/2022.
//

import Charts
import SwiftUI

// MARK: - PlaceholderChart
struct PlaceholderChart: View {
    @State private var feedData: [Feed] = []
    @State private var sleepData: [Sleep] = []
    @State private var didAnimateFeedAlready = false
    @State private var didAnimateSleepAlready = false
    let type: EntryType

    var body: some View {
        Group {
            switch type {
            case .liquidFeed, .solidFeed:
                dummyFeedChart
                    .redacted(reason: .placeholder)
            case .sleep:
                dummySleepChart
                    .redacted(reason: .placeholder)
            case .nappy:
                EmptyView()
            }
        }
        .disabled(true)
        .blur(radius: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .padding()
                .foregroundColor(.secondary)
            Text("Nothing to show just yet,\n add a \(type == .liquidFeed ? "feed" : "sleep")!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(.title2, design: .rounded))
        }
    }

    @ViewBuilder
    private var dummyFeedChart: some View {
        Chart(feedData) { feed in
            LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                     y: .value("Amount", feed.amount))
                .foregroundStyle(Color.blue.gradient)
        }
        .frame(height: 200)
        .frame(width: UIScreen.main.bounds.width)
        .onAppear {
            if !didAnimateFeedAlready {
                feedData.removeAll()
                for (index, item) in MockData.mockFeed.enumerated() {
                    withAnimation(.easeIn(duration: 0.2).delay(Double(index) * 0.1)) {
                        feedData.append(item)
                    }
                }
                didAnimateFeedAlready = true
            }
        }
    }

    @ViewBuilder
    private var dummySleepChart: some View {
        Chart(sleepData) { sleep in
            let dateValue = sleep.date.formatted(date: .abbreviated, time: .shortened)
            let amountValue = sleep.getDisplayableString()
            BarMark(x: .value("Time", dateValue),
                    y: .value("Amount", sleep.getTimeInterval()))
                .annotation(position: .overlay, alignment: .center) {
                    Text("\(amountValue)")
                        .foregroundColor(.white)
                }

                .foregroundStyle(Color.red.gradient)
        }
        .chartYAxis(.hidden)
        .frame(height: 200)
        .frame(width: UIScreen.main.bounds.width)
        .onAppear {
            if !didAnimateSleepAlready {
                sleepData.removeAll()
                for (index, item) in MockData.getMockSleep().enumerated() {
                    withAnimation(.easeIn(duration: 0.2).delay(Double(index) * 0.2)) {
                        sleepData.append(item)
                    }
                    didAnimateSleepAlready = true
                }
            }
        }
    }
}

// MARK: - PlaceholderChart_Previews
struct PlaceholderChart_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderChart(type: .liquidFeed)
        PlaceholderChart(type: .sleep)
    }
}

// MARK: - PlaceholderChart.MockData
extension PlaceholderChart {
    // MARK: - MockData

    enum MockData {
        static let mockFeed: [Feed] = [
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount(),
                 note: nil,
                 solidOrLiquid: Feed.SolidOrLiquid.solid),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount(),
                 note: nil,
                 solidOrLiquid: Feed.SolidOrLiquid.solid),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount(),
                 note: nil,
                 solidOrLiquid: Feed.SolidOrLiquid.liquid(type: .formula)),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount(),
                 note: nil,
                 solidOrLiquid: Feed.SolidOrLiquid.liquid(type: .formula)),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount(),
                 note: nil,
                 solidOrLiquid: Feed.SolidOrLiquid.liquid(type: .breast)),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount(),
                 note: nil,
                 solidOrLiquid: Feed.SolidOrLiquid.liquid(type: .breast)),
        ]
        .sorted(by: { $0.date < $1.date })

        static func getMockSleep() -> [Sleep] {
            let firstStart = Date.getRandomMockDate()
            let secondStart = Date.getRandomMockDate()
            let thirdStart = Date.getRandomMockDate()

            let firstEnd = Date.getRandomEndData(from: firstStart)
            let secondEnd = Date.getRandomEndData(from: secondStart)
            let thirdEnd = Date.getRandomEndData(from: thirdStart)

            return [
                Sleep(id: UUID().uuidString,
                      date: Date.getRandomMockDate(),
                      start: firstStart,
                      end:firstEnd),
                Sleep(id: UUID().uuidString,
                      date: Date.getRandomMockDate(),
                      start: secondStart,
                      end:secondEnd),
                Sleep(id: UUID().uuidString,
                      date: Date.getRandomMockDate(),
                      start: thirdStart,
                      end:thirdEnd),
            ].sorted(by: { $0.date < $1.date })
        }
    }
}
