//
//  DependencyInjectionProtocols.swift
//  BabyWize
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import Swinject

// MARK: - ResolverProtocol
public protocol ResolverProtocol {
    func resolve<T>(_ type: T.Type) -> T
}

// MARK: - Resolver
public final class Resolver: ResolverProtocol {
    public static let shared = Resolver()
    private var container: Container = .init()

    public func resolve<T>(_: T.Type) -> T {
        container.resolve(T.self)!
    }

    public func setDependencyContainer(_ container: Container) {
        self.container = container
    }
}
