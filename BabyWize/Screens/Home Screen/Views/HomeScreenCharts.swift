//
//  HomeScreenCharts.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Charts
import SwiftUI

// MARK: - HomeScreenCharts
struct HomeScreenCharts: View {
    @InjectedObject private var dataManager: BabyDataManager
    @State private var selectedChart: EntryType = .feed

    var body: some View {
        TabView {
            feedView
            sleepView
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    // MARK: - Views

    @ViewBuilder
    private var feedView: some View {
        let feedData = dataManager.feedData.getUpTo(limit: 6)
        VStack(alignment: .leading) {
            Text(feedInfoTitle)
                .font(.system(.title, design: .rounded))
                .padding(.leading)
            if feedData.isEmpty {
                PlaceholderChart(type: .feed)
            } else {
                Chart(feedData) { feed in
                    // This is a workaround because annotations don't work on line marks
                    BarMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                            y: .value("Amount", feed.amount))
                        .foregroundStyle(Color.clear)
                        .annotation(position: .top, alignment: .center) {
                            Text(feed.note ?? "")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    PointMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                             y: .value("Amount", feed.amount))
                        .foregroundStyle(Color.blue.gradient)
                    LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                             y: .value("Amount", feed.amount))
                        .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .frame(width: UIScreen.main.bounds.width)
            }
        }
    }


    @ViewBuilder
    private var sleepView: some View {
        let sleepData = dataManager.sleepData.getUpTo(limit: 3)
        VStack(alignment: .leading) {
            Text(sleepInfoTitle)
                .font(.system(.title, design: .rounded))
                .padding(.leading)
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

    // MARK: - Computed properties

    private var feedInfoTitle: String {
        if dataManager.feedData.isEmpty {
            return "Feed info"
        } else {
            let feedCount = dataManager.feedData.count >= 6 ? 6 : dataManager.feedData.count
            return "Feed info (last \(feedCount))"
        }
    }

    private var sleepInfoTitle: String {
        if dataManager.sleepData.isEmpty {
            return "Sleep info"
        } else {
            let feedCount = dataManager.sleepData.count >= 3 ? 3 : dataManager.sleepData.count
            return "Sleep info (last \(feedCount))"
        }
    }
}

// MARK: - HomeScreenCharts_Previews
struct HomeScreenCharts_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeScreenCharts()
        }
    }
}
