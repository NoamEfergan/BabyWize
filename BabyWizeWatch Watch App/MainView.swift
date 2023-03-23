//
//  MainView.swift
//  BabyWizeWatch Watch App
//
//  Created by Noam Efergan on 21/03/2023.
//

import SwiftUI
import Charts

// MARK: - MainView
struct MainView: View {
    var body: some View {
        TabView {
            FeedChart()
                .accessibilityLabel("Feed Chart")
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page)
        .padding()
    }
}

// MARK: - ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
