//
//  AddEntryWidget.swift
//  AddEntryWidget
//
//  Created by Noam Efergan on 23/07/2022.
//

import Intents
import SwiftUI
import WidgetKit
import Models

// MARK: - Provider
struct Provider: IntentTimelineProvider {
    private func getEntry(configuration: ConfigurationIntent, date: Date) -> SimpleEntry {
        guard let container = UserDefaults(suiteName: "group.babyData") else {
            return SimpleEntry(date: date,
                               configuration: configuration,
                               lastFeed: nil,
                               lastSleep: nil,
                               lastNappy: nil)
        }
        return SimpleEntry(date: date,
                           configuration: configuration,
                           lastFeed: container.string(forKey: "lastFeed"),
                           lastSleep: container.string(forKey: "lastSleep"),
                           lastNappy: container.string(forKey: "lastNappy"))
    }

    func placeholder(in _: Context) -> SimpleEntry {
        getEntry(configuration: ConfigurationIntent(), date: Date())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in _: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        completion(getEntry(configuration: configuration, date: Date()))
    }

    func getTimeline(for configuration: ConfigurationIntent, in _: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = getEntry(configuration: configuration, date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - SimpleEntry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let lastFeed: String?
    let lastSleep: String?
    let lastNappy: String?
}

// MARK: - AddEntryWidget
@main
struct AddEntryWidget: Widget {
    let kind = "AddEntryWidget"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Baby Wize")
        .description("Get the latest information about your baby, or quickly add a new entry!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - WidgetView
struct WidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            buttonView
                .widgetURL(URL(string: "widget://newEntry")!)
        case .systemMedium:
            summaryView
        default:
            EmptyView()
        }
    }

    private func getSummaryEntryView(_ title: String, _ value: String?) -> some View {
        VStack {
            Text(title)
                .font(.system(.body, design: .rounded))
            Spacer()
            Text(value ?? "None recorded")
                .fontWeight(.semibold)
                .font(.system(.title3, design: .rounded))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var summaryView: some View {
        HStack {
            getSummaryEntryView("Last Feed", entry.lastFeed)
            Divider()
                .overlay(.white)
            getSummaryEntryView("Last Change", entry.lastNappy)
            Divider()
                .overlay(.white)
            getSummaryEntryView("Last Sleep", entry.lastSleep)
        }

        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(AppColours.gradient)
    }

    private var buttonView: some View {
        VStack {
            Text("Add a new entry!")
                .multilineTextAlignment(.center)
            Image(systemName: "plus.circle.fill")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(AppColours.gradient)
    }
}

// MARK: - AddEntryWidget_Previews
struct AddEntryWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry:
            SimpleEntry(date: Date(),
                        configuration: ConfigurationIntent(),
                        lastFeed: "1 mins,\n43 secs",
                        lastSleep: "1 mins,\n43 secs",
                        lastNappy: Date.now.formatted()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetView(entry:
            SimpleEntry(date: Date(),
                        configuration: ConfigurationIntent(),
                        lastFeed: "1 mins,\n43 secs",
                        lastSleep: "1 mins,\n43 secs",
                        lastNappy: Date.now.formatted()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
