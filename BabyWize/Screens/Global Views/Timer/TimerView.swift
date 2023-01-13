//
//  TimerView.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/12/2022.
//

import SwiftUI
import Models

// MARK: - TimerView
struct TimerView: View {
    let startDate: Date
    var showingTitles = true
    @State private var timeSinceStart: TimeInterval = 0.0
    @State private var hours = "00"
    @State private var minutes = "00"
    @State private var seconds = "00"

    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack {
            CountdownTimeComponent(title: "Hours", showingTitles: showingTitles, counterValue: $hours)
            separator
            CountdownTimeComponent(title: "Minutes", showingTitles: showingTitles, counterValue: $minutes)
            separator
            CountdownTimeComponent(title: "Seconds", showingTitles: showingTitles, counterValue: $seconds)
        }
        .onReceive(timer) { _ in
            timeSinceStart += 1
            hours = timeSinceStart.hour.description.makeTwoDigit()
            minutes = timeSinceStart.minute.description.makeTwoDigit()
            seconds = timeSinceStart.second.description.makeTwoDigit()
        }
        .onAppear {
            timeSinceStart = Date().timeIntervalSince(startDate)
        }
    }

    private var separator: some View {
        Text(":")
            .font(.system(.title, design: .rounded))
            .padding(.bottom, showingTitles ? 25 : 10)
    }
}

// MARK: - TimerView_Previews
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TimerView(startDate: Date(timeInterval: 60 * -15, since: .now))
            TimerView(startDate: Date(timeInterval: 60 * -15, since: .now), showingTitles: false)
        }
    }
}
