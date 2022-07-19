//
//  SwinjectManager.swift
//  BabyTracker
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
    }
}
