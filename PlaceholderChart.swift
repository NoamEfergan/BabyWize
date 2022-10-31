//
//  PlaceholderChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 30/10/2022.
//

import SwiftUI
import Charts

// MARK: - PlaceholderChart
struct PlaceholderChart: View {
    let type: EntryType

    var body: some View {
        Group {
            switch type {
            case .feed:
                dummyFeedChart
            case .sleep:
                dummySleepChart
            case .nappy:
                EmptyView()
            }
        }
        .disabled(true)
        .opacity(0.2)
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .padding()
                .foregroundColor(.secondary)
            Text("Nothing to show just yet,\n add a \(type.rawValue)!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(.title2, design: .rounded))
        }
    }
    
    private var dummyFeedChart: some View {
        Chart(MockData.mockFeed) { feed in
            LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                     y: .value("Amount", feed.amount))
                .foregroundStyle(Color.blue.gradient)
        }
        .frame(height: 200)
        .frame(width: UIScreen.main.bounds.width)
    }
    
    private var dummySleepChart: some View {
        Chart(MockData.mockSleep) { sleep in
            let dateValue = sleep.date.formatted(date: .abbreviated, time: .shortened)
            let amountValue = sleep.duration.convertToTimeInterval().displayableString
            BarMark(x: .value("Time", dateValue),
                    y: .value("Amount", sleep.duration.convertToTimeInterval()))
                .annotation(position: .overlay, alignment: .center) {
                    Text("\(amountValue)")
                        .foregroundColor(.white)
                }

                .foregroundStyle(Color.red.gradient)
        }
        .chartYAxis(.hidden)
        .frame(height: 200)
        .frame(width: UIScreen.main.bounds.width)

    }
}

// MARK: - PlaceholderChart_Previews
struct PlaceholderChart_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderChart(type: .feed)
        PlaceholderChart(type: .sleep)
    }
}


extension PlaceholderChart {
    // MARK: - MockData
    enum MockData {
        static let mockFeed: [Feed] = [
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount()),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount()),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount()),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount()),
            Feed(id: UUID().uuidString,
                 date: Date.getRandomMockDate(),
                 amount: .getRandomFeedAmount())
        ]
        .sorted(by: { $0.date < $1.date })

        static let mockSleep: [Sleep] = [
            Sleep(id: UUID().uuidString,
                  date: Date.getRandomMockDate(),
                  duration: abs(Date.getRandomMockDate()
                      .timeIntervalSince(Date.getRandomMockDate()))
                      .hourMinuteSecondMS),
            Sleep(id: UUID().uuidString,
                  date: Date.getRandomMockDate(),
                  duration: abs(Date.getRandomMockDate()
                      .timeIntervalSince(Date.getRandomMockDate()))
                      .hourMinuteSecondMS),
            Sleep(id: UUID().uuidString,
                  date: Date.getRandomMockDate(),
                  duration: abs(Date.getRandomMockDate()
                      .timeIntervalSince(Date.getRandomMockDate()))
                      .hourMinuteSecondMS)
        ]
        .sorted(by: { $0.date < $1.date })
    }
}
