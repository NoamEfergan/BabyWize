//
//  SwinjectManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import Swinject

enum ContainerBuilder {
    static func buildMainContainer() -> Container {
        let mainContainer = Container()
        registerManagers(to: mainContainer)
        return mainContainer
    }

    private static func registerManagers(to container: Container) {
        container.register(BabyDataManager.self) { _ in
            BabyDataManager()
        }.inObjectScope(.container)
        container.register(WidgetManager.self) { _ in
            WidgetManager()
        }.inObjectScope(.container)
        container.register(UserDefaultManager.self) { _ in
            UserDefaultManager()
        }.inObjectScope(.container)
    }
}
