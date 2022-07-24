//
//  AddEntryWidget.swift
//  AddEntryWidget
//
//  Created by Noam Efergan on 23/07/2022.
//

import Intents
import SwiftUI
import WidgetKit


struct Provider: IntentTimelineProvider {
    private func getEntry(configuration: ConfigurationIntent, date: Date) -> SimpleEntry {
        guard let container = UserDefaults(suiteName: "group.babyData") else {
            return SimpleEntry(
                date: date,
                configuration: configuration,
                lastFeed: nil,
                lastSleep: nil,
                lastNappy: nil
            )
        }
        return SimpleEntry(
            date: date,
            configuration: configuration,
            lastFeed: container.string(forKey: "lastFeed"),
            lastSleep: container.string(forKey: "lastSleep"),
            lastNappy: container.object(forKey: "lastNappy") as? Date
        )
    }

    func placeholder(in context: Context) -> SimpleEntry {
        getEntry(configuration: ConfigurationIntent(), date: Date())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(getEntry(configuration: configuration, date: Date()))
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let lastFeed: String?
    let lastSleep: String?
    let lastNappy: Date?
}

struct AddEntryWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            LabeledContent("Last Feed", value: entry.lastFeed ?? "None recorded")
            Divider()
                .overlay(.white)
            LabeledContent("Last Nappy Change", value: entry.lastNappy?.formatted() ?? "None recorded")
            Divider()
                .overlay(.white)
            LabeledContent("Last Sleep", value: entry.lastSleep ?? "None recorded")
        }
        .fontWeight(.semibold)
        .frame(maxHeight: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(Color.blue.gradient)
    }
}

@main
struct AddEntryWidget: Widget {
    let kind: String = "AddEntryWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            AddEntryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Baby Tracker")
        .description("Get the latest information about your baby, or quickly add a new entry!")
        .supportedFamilies([.systemMedium])
    }
}

struct AddEntryWidget_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            lastFeed: "120 ml",
            lastSleep: "1 hr 20 min",
            lastNappy: Date()
        )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
