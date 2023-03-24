//
//  FeedChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 01/11/2022.
//

import Charts
import SwiftUI

// MARK: - FeedChart
struct FeedChart: View {
    var feedData: [Feed]
    var breastFeedData: [BreastFeed]

    var showTitle = true
    @State private var isShowingJoint = true
    @InjectedObject private var defaultManager: UserDefaultManager

    private let timeTitle = "Time"
    private let amountTitle = "Amount"
    private let durationTitle = "Duration"
    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        VStack(alignment: .leading) {
            if showTitle {
                headerView
            }
            if feedData.isEmpty && breastFeedData.isEmpty {
                PlaceholderChart(type: .liquidFeed)
                    .onAppear {
                        isShowingJoint = true
                    }
                    .onDisappear {
                        isShowingJoint = defaultManager.chartConfiguration == .joint
                    }
            } else {
                if showTitle {
                    if isShowingJoint {
                        jointChart
                    } else {
                        separateCharts
                    }
                } else {
                    separateCharts
                }
            }
        }
        .onAppear {
            isShowingJoint = defaultManager.chartConfiguration == .joint
        }
        .onChange(of: defaultManager.chartConfiguration) { newValue in
            isShowingJoint = newValue == .joint
        }
        .animation(.easeInOut, value: isShowingJoint)
    }

    // MARK: - Views

    @ViewBuilder
    private var headerView: some View {
        ViewThatFits {
            HStack {
                Text(feedInfoTitle)
                    .font(.system(.title, design: .rounded))
                    .padding(.leading)
                Spacer()
                #if os(iOS)
                menuButton
                #endif
            }
            VStack {
                Text(feedInfoTitle)
                    .font(.system(.title, design: .rounded))
                    .padding(.leading)
                Spacer()
                #if os(iOS)
                menuButton
                #endif
            }
        }
    }

    @ViewBuilder
    private var menuButton: some View {
        VStack(alignment: .leading) {
            Text("Displaying:")
            #if os(iOS)
            Menu(defaultManager.chartConfiguration.rawValue.capitalized) {
                ForEach(ChartConfiguration.allCases, id: \.self) { config in
                    Button(config.rawValue.capitalized) {
                        withAnimation(.easeInOut) {
                            defaultManager.chartConfiguration = config
                        }
                    }
                    .fontWeight(.heavy)
                }
            }
            .foregroundStyle(AppColours.tintPurple.gradient)
            #endif
        }
        .foregroundColor(.secondary)
        .font(.system(.subheadline, design: .rounded))
        .padding(.trailing, 5)
        .accessibilityElement()
        .accessibilityLabel("Displaying feed charts")
        .accessibilityValue(defaultManager.chartConfiguration.rawValue)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Tap this to switch from joint charts to separate charts")
    }

    @ViewBuilder
    private var separateCharts: some View {
        if !feedData.filter(\.isLiquids).isEmpty {
            ChartContainer(title: "Liquids",
                           data: feedData.filter(\.isLiquids),
                           plotWidth: plotWidth,
                           foregroundGradient: Color.blue.gradient)
        }
        if !feedData.filter(\.isSolids).isEmpty {
            ChartContainer(title: "Solids",
                           data: feedData.filter(\.isSolids),
                           plotWidth: plotWidth,
                           foregroundGradient: Color.orange.gradient)
        }

        breastFeedChart
    }

    @ViewBuilder
    private var jointChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !feedData.isEmpty {
                Text("Formula and solid feeds")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.leading)

                ScrollView(.horizontal) {
                    Chart(feedData.sorted(by: { $0.date < $1.date })) { feed in
                        BWChart(feed: feed,
                                series: feed.solidOrLiquid.title,
                                foregroundGradient: feed.solidOrLiquid == .solid
                                    ? Color.orange.gradient
                                    : Color.blue.gradient)
                    }
                    .feedChartModifier(plotWidth: plotWidth)
                }
            }

            breastFeedChart
        }

        .scrollIndicators(.visible)
    }

    @ViewBuilder
    private var breastFeedChart: some View {
        if !breastFeedData.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Breast feeds")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.leading)
                ScrollView(.horizontal) {
                    Chart(breastFeedData.sorted(by: { $0.date < $1.date })) { feed in
                        getBreastFeedChart(for: feed)
                    }
                    .feedChartModifier(plotWidth: plotWidth)
                    .chartYAxis(.hidden)
                }
                .scrollIndicators(.visible)
            }
            .transition(.push(from: .top))
            .frame(minHeight: 200)
        }
    }

    // MARK: - Breast feeding chart

    @ChartContentBuilder
    private func getBreastFeedChart(for feed: BreastFeed) -> some ChartContent {
        let duration = feed.getDisplayableString()
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        PointMark(x: .value(timeTitle, date),
                  y: .value(durationTitle, duration))
            .accessibilityLabel(feed.date.formatted())
            .accessibilityValue("Breast feed, \(duration)")
            .foregroundStyle(Color.pink.gradient)
            .annotation(position: .top, alignment: .center) {
                Text("\(duration)")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

        LineMark(x: .value(timeTitle, date),
                 y: .value(durationTitle, duration),
                 series: .value("Breast feeds", "breast feeds"))
            .alignsMarkStylesWithPlotArea()
            .foregroundStyle(Color.pink.gradient)
            .accessibilityHidden(true)
    }

    // MARK: - Charts methods

    private func getBarMark(for feed: Feed, amount: Double) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        return BarMark(x: .value(timeTitle, date),
                       y: .value(amountTitle, amount))
    }

    private func getPointMark(for feed: Feed, amount: Double) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        return PointMark(x: .value(timeTitle, date),
                         y: .value(amountTitle, amount))
    }

    private func getLineMark(for feed: Feed, amount: Double, series: String) -> some ChartContent {
        let date = feed.date.formatted(date: .omitted, time: .shortened)
        return LineMark(x: .value(timeTitle, date),
                        y: .value(amountTitle, amount),
                        series: .value(series, series))
    }

    // MARK: - Private computed variables

    private var feedInfoTitle: String {
        if feedData.isEmpty {
            return "Feed info"
        } else {
            let feedCount = feedData.count >= 6 ? 6 : feedData.count
            return "Feed info (last \(feedCount))"
        }
    }


    private var plotWidth: CGFloat {
        350 + sizeModifier
    }

    private var sizeModifier: Double {
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
}

// MARK: - FeedChart_Previews
struct FeedChart_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            FeedChart(feedData: MockEntries.mockFeed.getUpTo(limit: 7),
                      breastFeedData: MockEntries.mockBreast)
        }
        ScrollView {
            FeedChart(feedData: MockEntries.mockFeed,
                      breastFeedData: MockEntries.mockBreast,
                      showTitle: false)
        }
    }
}
