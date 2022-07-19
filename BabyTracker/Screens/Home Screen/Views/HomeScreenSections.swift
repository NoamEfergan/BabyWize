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
        Section("feed info (last 12 hours)") {
            Chart(feedManager.data) { feed in
                LineMark(
                    x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                    y: .value("Amount", feed.amount)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
        }
        Section("sleep info (last 12 hours") {
            Chart(sleepManager.data) { sleep in
                BarMark(
                    x: .value("Time", sleep.date.formatted(date: .omitted, time: .shortened)),
                    y: .value("Amount", sleep.duration)
                )
                .foregroundStyle(Color.red.gradient)
            }
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
