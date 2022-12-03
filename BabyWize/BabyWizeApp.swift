//
//  BabyWizeApp.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//


import SwiftUI
import Swinject
import AppIntents

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil)
        -> Bool {
        true
    }
}

// MARK: - NavigationViewModel
final class NavigationViewModel: ObservableObject {
    @Published var path: [Screens] = []
}

// MARK: - BabyWizeApp
@main
struct BabyWizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var navigationVM = NavigationViewModel()
    @AppStorage(UserConstants.isLoggedIn) private var savedIsUserLoggedIn: Bool?

    init() {
        let mainContainer = ContainerBuilder.buildMainContainer()
        Resolver.shared.setDependencyContainer(mainContainer)
    }

    @Environment(\.scenePhase) var scenePhase
    @StateObject private var dataController = DataController()
    @State private var isShowingSplash = true
    var body: some Scene {
        WindowGroup {
            ZStack {
                ZStack {
                    Theme.mainGradient
                        .ignoresSafeArea()
                    Image("NoBGLogo")
                        .resizable()
                        .aspectRatio(1*1, contentMode: .fit)
                        .frame(width: 185)
                        .rotationEffect(Angle(degrees: isShowingSplash ? 360 : 0.0))
                }
                .scaleEffect(isShowingSplash ? 1 : 40)
                .opacity(isShowingSplash ? 1 : 0)
                HomeView()
                    .environmentObject(navigationVM)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environment(\.colorScheme, .light)
                    .opacity(isShowingSplash ? 0 : 1)
            }
            .animation(.easeInOut(duration: 1), value: isShowingSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isShowingSplash.toggle()
                }
            }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .background {
                WidgetManager().setLatest()
            }
        }
    }
}

// MARK: - ShortcutProvider
struct ShortcutProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: LogFeed(),
                    phrases: [
                        "Log a feed on \(.applicationName)"
                    ])
    }
}

