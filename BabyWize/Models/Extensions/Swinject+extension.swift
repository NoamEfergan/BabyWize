//
//  Swinject + extension.swift
//  BabyWize
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
        wrappedValue = resolver.resolve(Component.self)
    }
}

@propertyWrapper public struct InjectedObject<Service>: DynamicProperty where Service: ObservableObject {
    @ObservedObject private var service: Service
    public init() {
        service = Resolver.shared.resolve(Service.self)
    }

    public var wrappedValue: Service {
        get { service }
        mutating set { service = newValue }
    }

    public var projectedValue: ObservedObject<Service>.Wrapper {
        $service
    }
}
