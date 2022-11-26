//
//  SwinjectManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import Swinject
import Firebase
import FirebaseCore
import FirebaseFirestore

enum ContainerBuilder {
    static func buildMainContainer() -> Container {
        let mainContainer = Container()
        registerManagers(to: mainContainer)
        return mainContainer
    }

    private static func registerManagers(to container: Container) {
        FirebaseApp.configure()
        container.register(UserDefaultManager.self) { _ in
            UserDefaultManager()
        }.inObjectScope(.container)
        container.register(AuthViewModel.self) { _ in
            AuthViewModel()
        }.inObjectScope(.container)
        container.register(BabyDataManager.self) { _ in
            BabyDataManager()
        }.inObjectScope(.container)
        container.register(WidgetManager.self) { _ in
            WidgetManager()
        }.inObjectScope(.container)
        container.register(FirebaseManager.self) { r in
            FirebaseManager(
                authVM: r.resolve(AuthViewModel.self)!,
                defaultsManager: r.resolve(UserDefaultManager.self)!
            )
        }.inObjectScope(.container)
        
    }
}
