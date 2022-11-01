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
    let sleepData: [Sleep]
    var showTitle: Bool = true
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
                Chart(sleepData) { sleep in
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
        SleepChart(sleepData: PlaceholderChart.MockData.mockSleep)
    }
}
