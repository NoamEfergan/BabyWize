//
//  Swinject + extension.swift
//  BabyTracker
//
//  Created by Noam Efergan on 18/07/2022.
//

import Foundation
import SwiftUI
import Swinject

@propertyWrapper
struct Inject<Component> {
    let wrappedValue: Component

    init(resolver: ResolverProtocol = Resolver.shared) {
        self.wrappedValue = resolver.resolve(Component.self)
    }
}

@propertyWrapper public struct InjectedObject<Service>: DynamicProperty where Service: ObservableObject {
    @ObservedObject private var service: Service
    public init() {
        self.service = Resolver.shared.resolve(Service.self)
    }

    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }

    public var projectedValue: ObservedObject<Service>.Wrapper {
        return $service
    }
}
