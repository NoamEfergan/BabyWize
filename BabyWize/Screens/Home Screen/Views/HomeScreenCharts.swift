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

    var body: some View {
        TabView {
            FeedChart(feedData: dataManager.feedData.getUpTo(limit: 6),
                      breastFeedData: dataManager.breastFeedData.getUpTo(limit: 6))
                .frame(width: UIScreen.main.bounds.width)
                .accessibilityLabel("Feed Chart")
            SleepChart(sleepData: dataManager.sleepData.getUpTo(limit: 3))
                .accessibilityLabel("Sleep Chart")
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(minHeight: 200)
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
