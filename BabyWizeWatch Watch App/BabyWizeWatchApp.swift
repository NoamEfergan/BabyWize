//
//  BabyWizeWatchApp.swift
//  BabyWizeWatch Watch App
//
//  Created by Noam Efergan on 21/03/2023.
//

import SwiftUI

@main
struct BabyWizeWatch_Watch_AppApp: App {
    let watchManager = WatchAppManager()
    var body: some Scene {
        WindowGroup {
            MainView()
                .task {
                    watchManager.startSession()
                }
        }
    }
}
