//
//  BabyWizeApp.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//

import FirebaseCore
import SwiftUI
import Swinject

// class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//
//    return true
//  }
// }

@main
struct BabyWizeApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        let mainContainer = ContainerBuilder.buildMainContainer()
        Resolver.shared.setDependencyContainer(mainContainer)
        FirebaseApp.configure()
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
