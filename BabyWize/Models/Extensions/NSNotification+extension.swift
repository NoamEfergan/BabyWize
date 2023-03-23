//
//  NSNotification+extension.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/11/2022.
//

import Foundation

extension Notification.Name {
    static let didLogOut = Notification.Name("did-log-out")
    static let didLogIn = Notification.Name("did-log-in")
}

extension NSNotification {
    // Feed
    static let feedTimerStart = NSNotification.Name("FeedTimerStart")
    static let feedTimerEnd = NSNotification.Name("FeedTimerEnd")
    // Sleep
    static let sleepTimerStart = NSNotification.Name("SleepTimerStart")
    static let sleepTimerEnd = NSNotification.Name("SleepTimerEnd")
}
