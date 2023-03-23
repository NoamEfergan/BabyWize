//
//  SwinjectManager.swift
//  BabyWizeWatch Watch App
//
//  Created by Noam Efergan on 23/03/2023.
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
        container.register(UserDefaultManager.self) { _ in
            UserDefaultManager()
        }.inObjectScope(.container)
    }
}
