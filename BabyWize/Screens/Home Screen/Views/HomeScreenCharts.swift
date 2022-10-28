//
//  HomeScreenCharts.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Charts
import Snappable
import SwiftUI

// MARK: - HomeScreenCharts

struct HomeScreenCharts: View {
    @InjectedObject private var dataManager: BabyDataManager
    private let nothingYetTitle = "Nothing to show yet!"

    @ViewBuilder
    private var feedView: some View {
        let feedData = dataManager.feedData.getUpTo(limit: 6)
        VStack {
            Text(feedInfoTitle)
                .font(.system(.title, design: .rounded))
            Chart(feedData) { feed in
                LineMark(x: .value("Time", feed.date.formatted(date: .omitted, time: .shortened)),
                         y: .value("Amount", feed.amount))
                    .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
            .frame(width: UIScreen.main.bounds.width)
        }
    }

    @ViewBuilder
    private var sleepView: some View {
        let sleepData = dataManager.sleepData.getUpTo(limit: 3)
        VStack {
            Text(sleepInfoTitle)
                .font(.system(.title, design: .rounded))
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

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                feedView
                    .snapID(feedInfoTitle)
                sleepView
                    .padding(.horizontal)
                    .snapID(sleepInfoTitle)
            }
        }
        .snappable()
    }

    private var feedInfoTitle: String {
        if dataManager.feedData.isEmpty {
            return nothingYetTitle
        } else {
            let feedCount = dataManager.feedData.count >= 6 ? 6 : dataManager.feedData.count
            return "Feed info (last \(feedCount))"
        }
    }

    private var sleepInfoTitle: String {
        if dataManager.sleepData.isEmpty {
            return nothingYetTitle
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
