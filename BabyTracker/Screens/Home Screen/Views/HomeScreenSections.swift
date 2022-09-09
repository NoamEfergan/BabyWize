//
//  HomeScreenSections.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Charts
import SwiftUI

// MARK: - HomeScreenSections
struct HomeScreenSections: View {
    @InjectedObject private var dataManager: BabyDataManager


    var body: some View {
        let feedInfoTitle =
            "feed info \(dataManager.feedData.isEmpty ? "" : "(last \(dataManager.feedData.count >= 6 ? 6 : dataManager.feedData.count))")"

        let sleepInfoTitle =
            "sleep info \(dataManager.sleepData.isEmpty ? "" : "(last \(dataManager.sleepData.count >= 3 ? 3 : dataManager.sleepData.count))")"

        Section(feedInfoTitle) {
            if dataManager.feedData.isEmpty {
                Text("Nothing to show yet, add a feed!")
            } else {
                Chart(dataManager.feedData.count >= 6
                    ? Array(dataManager.feedData.suffix(6))
                    : dataManager.feedData) { feed in
                        LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                                 y: .value("Amount", feed.amount))
                            .foregroundStyle(Color.blue.gradient)
                    }
                    .frame(height: 200)
                NavigationLink("More Info", value: InfoScreens.feed)
            }
        }
        Section(sleepInfoTitle) {
            if dataManager.sleepData.isEmpty {
                Text("Nothing to show yet, add a sleep!")
            } else {
                Chart(dataManager.sleepData.count >= 3
                    ? Array(dataManager.sleepData.suffix(3))
                    : dataManager.sleepData) { sleep in
                        let dateValue = sleep.date.formatted(date: .omitted, time: .shortened)
                        let amountValue = sleep.duration.convertToTimeInterval().displayableString
                        BarMark(x: .value("Time", "\(dateValue)\n \(amountValue)"),
                                y: .value("Amount", sleep.duration.convertToTimeInterval()))
                            .foregroundStyle(Color.red.gradient)
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 200)
                NavigationLink("More Info", value: InfoScreens.sleep)
            }
        }
    }
}

// MARK: - HomeScreenSections_Previews
struct HomeScreenSections_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HomeScreenSections()
        }
    }
}
