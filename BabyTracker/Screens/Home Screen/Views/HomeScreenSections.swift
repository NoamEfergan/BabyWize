//
//  HomeScreenSections.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Charts
import SwiftUI

struct HomeScreenSections: View {
    @InjectedObject private var feedManager: FeedManager
    @InjectedObject private var sleepManager: SleepManager

    var body: some View {
        Section("feed info (last \(feedManager.data.count >= 6 ? 6 : feedManager.data.count))") {
            Chart(feedManager.data.count >= 6 ? Array(feedManager.data.suffix(6)) : feedManager.data) { feed in
                LineMark(
                    x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                    y: .value("Amount", feed.amount)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
        }
        Section("sleep info (last \(sleepManager.data.count >= 3 ? 3 : sleepManager.data.count))") {
            Chart(sleepManager.data.count >= 3 ? Array(sleepManager.data.suffix(3)) : sleepManager.data) { sleep in
                let dateValue = sleep.date.formatted(date: .omitted, time: .shortened)
                let amountValue = sleep.duration.convertToTimeInterval().displayableString
                BarMark(
                    x: .value("Time", "\(dateValue)\n \(amountValue)"),
                    y: .value("Amount", sleep.duration.convertToTimeInterval())
                )
                .foregroundStyle(Color.red.gradient)
            }
            .chartYAxis(.hidden)
            .frame(height: 200)
        }
    }
}

struct HomeScreenSections_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HomeScreenSections()
        }
    }
}
