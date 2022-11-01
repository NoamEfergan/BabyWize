//
//  DependencyInjectionProtocols.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import Swinject

// MARK: - ResolverProtocol
protocol ResolverProtocol {
    func resolve<T>(_ type: T.Type) -> T
}

// MARK: - Resolver
final class Resolver: ResolverProtocol {
    static let shared = Resolver()
    private var container: Container = .init()

    func resolve<T>(_: T.Type) -> T {
        container.resolve(T.self)!
    }

    func setDependencyContainer(_ container: Container) {
        self.container = container
    }
}
