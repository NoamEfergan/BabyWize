//
//  BabyWizeApp.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//

import SwiftUI
import Swinject

@main
struct BabyWizeApp: App {
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
