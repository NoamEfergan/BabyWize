//
//  BabyWizeApp.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//

import ActivityKit
import AppIntents
import SwiftUI
import Swinject

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
    @State private var _sleepActivity: Any?
    @State private var _feedActivity: Any?
    @available(iOS 16.1, *)
    private var sleepActivity: Activity<SleepActivityAttributes>? {
        _sleepActivity as? Activity<SleepActivityAttributes>
    }

    @available(iOS 16.1, *)
    private var feedActivity: Activity<FeedActivityAttributes>? { _feedActivity as? Activity<FeedActivityAttributes> }

    init() {
        let mainContainer = ContainerBuilder.buildMainContainer()
        Resolver.shared.setDependencyContainer(mainContainer)
    }

    @Environment(\.scenePhase) var scenePhase
    @State private var isShowingSplash = true
    var body: some Scene {
        WindowGroup {
            ZStack {
                ZStack {
                    AppColours.gradient
                        .ignoresSafeArea()
                    Image(decorative: "NoBGLogo")
                        .resizable()
                        .aspectRatio(1*1, contentMode: .fit)
                        .frame(width: 185)
                        .rotationEffect(Angle(degrees: isShowingSplash ? 360 : 0.0))
                        .accessibilityHidden(true)
                }
                .scaleEffect(isShowingSplash ? 1 : 40)
                .opacity(isShowingSplash ? 1 : 0)
                HomeView()
                    .environmentObject(navigationVM)
                    .environment(\.colorScheme, .light)
                    .opacity(isShowingSplash ? 0 : 1)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.sleepTimerStart)) { _ in
                        if #available(iOS 16.1, *) {
                            startSleepActivity()
                        } else {
                            print("Tried to start live activity from iOS 16")
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.sleepTimerEnd)) { _ in
                        if #available(iOS 16.1, *) {
                            endSleepActivity()
                        } else {
                            // Fallback on earlier versions
                            print("Tried to end live activity from iOS 16")
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.feedTimerStart)) { _ in
                        if #available(iOS 16.1, *) {
                            startFeedActivity()
                        } else {
                            print("Tried to start live activity from iOS 16")
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.feedTimerEnd)) { _ in
                        if #available(iOS 16.1, *) {
                            endFeedActivity()
                        } else {
                            // Fallback on earlier versions
                            print("Tried to end live activity from iOS 16")
                        }
                    }
            }
            .animation(.easeInOut(duration: 1), value: isShowingSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isShowingSplash.toggle()
                }
            }
            .task {
                do {
                    let feedIntent = LogFeed()
                    let sleepIntent = LogSleep()
                    try await IntentDonationManager.shared.donate(intent: feedIntent)
                    try await IntentDonationManager.shared.donate(intent: sleepIntent)
                } catch {
                    print("Failed with error: \(error.localizedDescription)")
                }
            }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .background {
                WidgetManager().setLatest()
            }
        }
    }

    @available(iOS 16.1, *)
    private func startSleepActivity() {
        Task {
            if sleepActivity?.activityState == .active {
                await sleepActivity?.end(using: nil, dismissalPolicy: .immediate)
            }
            let attributes = SleepActivityAttributes(name: "Baby Sleep Timer")
            let state = SleepActivityAttributes.ContentState()
            _sleepActivity = try? Activity<SleepActivityAttributes>
                .request(attributes: attributes, contentState: state, pushType: nil)
            print("Started live sleep activity")
        }
    }

    @available(iOS 16.1, *)
    private func startFeedActivity() {
        Task {
            if feedActivity?.activityState == .active {
                await feedActivity?.end(using: nil, dismissalPolicy: .immediate)
            }
            let attributes = FeedActivityAttributes(name: "Baby Feed Timer")
            let state = FeedActivityAttributes.ContentState()
            _feedActivity = try? Activity<FeedActivityAttributes>
                .request(attributes: attributes, contentState: state, pushType: nil)
            print("Started live feed activity")
        }
    }

    @available(iOS 16.1, *)
    private func endSleepActivity() {
        Task {
            guard let sleepActivity else {
                return
            }
            await sleepActivity.end(using: nil, dismissalPolicy: .immediate)
            print("Stopped live sleep activity")
        }
    }

    @available(iOS 16.1, *)
    private func endFeedActivity() {
        Task {
            guard let feedActivity else {
                return
            }
            await feedActivity.end(using: nil, dismissalPolicy: .immediate)
            print("Stopped live feed activity")
        }
    }
}

// MARK: - ShortcutProvider
struct ShortcutProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .pink
    static var appShortcuts: [AppShortcut] =
        [
            AppShortcut(intent: LogFeed(),
                        phrases: [
                            "Log a feed on \(.applicationName)"
                        ]),
            AppShortcut(intent: LogSleep(),
                        phrases: [
                            "Log a sleep on \(.applicationName)"
                        ]),
            AppShortcut(intent: LogNappy(),
                        phrases: [
                            "Log a nappy change on \(.applicationName)"
                        ])
        ]
}

