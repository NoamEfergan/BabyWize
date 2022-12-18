//
//  SleepActivityLiveActivity.swift
//  SleepActivity
//
//  Created by Noam Efergan on 18/12/2022.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - SleepActivityAttributes
struct SleepActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

// MARK: - SleepActivityLiveActivity
@available(iOS 16.1, *)
struct SleepActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SleepActivityAttributes.self) { _ in
            // Lock screen/banner UI goes here
            timeView
                .padding(.vertical)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(Color.black)
        }
    dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    timeView
                }
            } compactLeading: {
                Text("Sleep")

            } compactTrailing: {
                iconImage
            } minimal: {
                iconImage
            }
            .widgetURL(URL(string: "widget://openSleep"))
            .keylineTint(Color.red)
        }
    }

    private var timeView: some View {
        VStack(alignment: .center) {
            Text("Baby's asleep for:")
                .font(.system(.title2, design: .rounded))
                .bold()
            Text(Date.now, style: .timer)
                .font(.system(.title, design: .rounded))
                .bold()
                .multilineTextAlignment(.center)
        }
    }

    private var iconImage: some View {
        Image("BabyWize")
            .resizable()
            .frame(width: 34, height: 34)
    }
}

// MARK: - SleepActivityLiveActivity_Previews
@available(iOS 16.2, *)
struct SleepActivityLiveActivity_Previews: PreviewProvider {
    static let attributes = SleepActivityAttributes(name: "Me")
    static let contentState = SleepActivityAttributes.ContentState()

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
