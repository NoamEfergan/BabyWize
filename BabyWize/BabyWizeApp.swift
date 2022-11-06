//
//  BabyWizeApp.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI
import Swinject

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil)
        -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - BabyWizeApp
@main
struct BabyWizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject private var authVM = AuthViewModel()
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
                SplashScreen()
                    .scaleEffect(isShowingSplash ? 1 : 40)
                    .opacity(isShowingSplash ? 1 : 0)
                LoadingView(isShowing: $authVM.isLoading, text: "Logging you back in...") {
                    HomeView()
                        .environment(\.managedObjectContext, dataController.container.viewContext)
                        .environment(\.colorScheme, .light)
                }
                .opacity(isShowingSplash ? 0 : 1)
            }
            .animation(.easeInOut(duration: 0.5), value: isShowingSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isShowingSplash.toggle()
                }
            }
            .task {
                if let savedIsUserLoggedIn,
                   savedIsUserLoggedIn,
                   let credentials = try? KeychainManager.fetchCredentials() {
                    await authVM.login(email: credentials.email, password: credentials.password)
                } else {
                    authVM.isLoading = false
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
