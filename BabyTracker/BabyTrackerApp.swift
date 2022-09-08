//
//  BabyTrackerApp.swift
//  BabyTracker
//
//  Created by Noam Efergan on 17/07/2022.
//

import SwiftUI
import Swinject


@main
struct BabyTrackerApp: App {
    
    init() {
        let mainContainer = ContainerBuilder.buildMainContainer()
        Resolver.shared.setDependencyContainer(mainContainer)
    }
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .background {
                WidgetManager().setLatest()
            }
        }
    }
}
