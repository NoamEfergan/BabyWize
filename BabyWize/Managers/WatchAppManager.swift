//
//  WatchAppManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 21/03/2023.
//

import Foundation
import WatchConnectivity

final class WatchAppManager: NSObject, WCSessionDelegate {
    override init() {
        super.init()
    }

    func startSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            print("watch session not supported")
        }
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Session became active")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("session deactive")
    }

    // Handle received messages from the Watch app
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle the message data here
    }
}
