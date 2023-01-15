//
//  FeedChart.swift
//  BabyWize
//
//  Created by Noam Efergan on 01/11/2022.
//

import Charts
import SwiftUI
import Models
import Managers

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
                Group {
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
        }
        .onAppear {
            isShowingJoint = defaultManager.chartConfiguration == .joint
        }
        .onChange(of: defaultManager.chartConfiguration, perform: { newValue in
            isShowingJoint = newValue == .joint
        })
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
                menuButton
            }
            VStack {
                Text(feedInfoTitle)
                    .font(.system(.title, design: .rounded))
                    .padding(.leading)
                Spacer()
                menuButton
            }
        }
    }

    @ViewBuilder
    private var menuButton: some View {
        VStack(alignment: .leading) {
            Text("Displaying:")
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
            VStack(alignment: .leading, spacing: 0) {
                Text("Liquids")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.leading)
                ScrollView(.horizontal) {
                    Chart(feedData.filter(\.isLiquids).sorted(by: { $0.date < $1.date })) { feed in
                        getLiquidsChart(for: feed)
                    }
                    .chartModifier(plotWidth: plotWidth)
                }
                .scrollIndicators(.visible)
            }
            .transition(.push(from: .bottom))
            .frame(minHeight: 200)
        }
        if !feedData.filter(\.isSolids).isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Solids")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.leading)
                ScrollView(.horizontal) {
                    Chart(feedData.filter(\.isSolids).sorted(by: { $0.date < $1.date })) { feed in
                        getSolidsChart(for: feed)
                    }
                    .chartModifier(plotWidth: plotWidth)
                }
                .scrollIndicators(.visible)
            }
            .transition(.push(from: .top))
            .frame(minHeight: 200)
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
                        if feed.solidOrLiquid == .solid {
                            getSolidsChart(for: feed)
                        } else {
                            getLiquidsChart(for: feed)
                        }
                    }
                    .chartModifier(plotWidth: plotWidth)
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
                    .chartModifier(plotWidth: plotWidth)
                    .chartYAxis(.hidden)
                }
                .scrollIndicators(.visible)
            }
            .transition(.push(from: .top))
            .frame(minHeight: 200)
        }
    }

    // MARK: - Liquid chart

    @ChartContentBuilder
    private func getLiquidsChart(for feed: Feed) -> some ChartContent {
        let unit = feed.amount.roundDecimalPoint()
        getBarMark(for: feed, amount: unit)
            .foregroundStyle(Color.clear)
            .annotation(position: .top, alignment: .center) {
                Text(feed.note ?? "")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityHidden(true)

        getPointMark(for: feed, amount: unit)
            .foregroundStyle(Color.blue.gradient)
            .annotation(position: .bottom, alignment: .center) {
                Text(feed.amount.liquidFeedDisplayableAmount())
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityLabel(feed.date.formatted())
            .accessibilityValue("\(feed.amount.liquidFeedDisplayableAmount()), \(feed.solidOrLiquid.title)")
        getLineMark(for: feed, amount: unit, series: "Liquids")
            .foregroundStyle(Color.blue.gradient)
            .accessibilityHidden(true)
    }

    // MARK: - Solid chart

    @ChartContentBuilder
    private func getSolidsChart(for feed: Feed) -> some ChartContent {
        let amount = feed.amount
        getBarMark(for: feed, amount: amount)
            .foregroundStyle(Color.clear)
            .annotation(position: .top, alignment: .center) {
                Text(feed.note ?? "")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityHidden(true)

        getPointMark(for: feed, amount: amount)
            .foregroundStyle(Color.orange.gradient)
            .annotation(position: .bottom, alignment: .center) {
                Text(amount.solidFeedDisplayableAmount())
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .accessibilityLabel(feed.date.formatted())
            .accessibilityValue("\(feed.amount.solidFeedDisplayableAmount()), \(feed.solidOrLiquid.title)")
        getLineMark(for: feed, amount: amount, series: "Solids")
            .foregroundStyle(Color.orange.gradient)
            .accessibilityHidden(true)
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
            FeedChart(feedData: PlaceholderChart.MockData.mockFeed.getUpTo(limit: 7),
                      breastFeedData: PlaceholderChart.MockData.mockBreast)
        }
        ScrollView {
            FeedChart(feedData: PlaceholderChart.MockData.mockFeed,
                      breastFeedData: PlaceholderChart.MockData.mockBreast,
                      showTitle: false)
        }
    }
}

// MARK: - ChartModifier
private struct ChartModifier: ViewModifier {
    let plotWidth: CGFloat
    func body(content: Content) -> some View {
        content
            .chartPlotStyle(content: { plotArea in
                plotArea.frame(width: plotWidth)
            })
            .frame(maxHeight: .greatestFiniteMagnitude)
            .frame(minWidth: UIScreen.main.bounds.width)
            .frame(maxWidth: .greatestFiniteMagnitude)
            .padding()
    }
}

private extension View {
    func chartModifier(plotWidth: CGFloat) -> some View {
        modifier(ChartModifier(plotWidth: plotWidth))
    }
}
