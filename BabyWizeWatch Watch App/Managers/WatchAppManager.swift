//
//  WatchAppManager.swift
//  BabyWizeWatch Watch App
//
//  Created by Noam Efergan on 21/03/2023.
//

import Foundation
import WatchConnectivity

final class WatchAppManager: NSObject, WCSessionDelegate {
    let session = WCSession.default
    override init() {
        super.init()
    }

    func startSession() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        } else {
            print("watch session not supported on watch")
        }
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Session became active on watch")
    }

    // Handle received messages from the Watch app
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle the message data here
    }
}
