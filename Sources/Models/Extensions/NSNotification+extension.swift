//
//  NSNotification+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/11/2022.
//

import Foundation

public extension Notification.Name {
    static let didLogOut = Notification.Name("did-log-out")
    static let didLogIn = Notification.Name("did-log-in")
}
