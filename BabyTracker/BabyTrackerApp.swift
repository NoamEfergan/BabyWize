//
//  BabyTrackerApp.swift
//  BabyTracker
//
//  Created by Noam Efergan on 17/07/2022.
//

import SwiftUI
import Swinject

class MyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let mainContainer = ContainerBuilder.buildMainContainer()
        Resolver.shared.setDependencyContainer(mainContainer)
        return true
    }
}

@main
struct BabyTrackerApp: App {
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .background {
                WidgetManager().setLatest()
            }
        }
    }
}
