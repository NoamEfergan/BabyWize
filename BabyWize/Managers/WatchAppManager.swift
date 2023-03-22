//
//  WatchAppManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 21/03/2023.
//

import Foundation
import WatchConnectivity

final class WatchAppManager: NSObject, WCSessionDelegate {
    let session: WCSession = .default
    override init() {
        super.init()
    }

    func startSession() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        } else {
            print("watch session not supported")
        }
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Session became \(activationState)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("session deactivated")
    }

    // Handle received messages from the Watch app
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle the message data here
    }

    func sendData(_ data: Data) {
        session.sendMessageData(data, replyHandler: nil)
    }

    func sendDictionary(_ data: [Constants: Any]) {
        let dictionary: [String: Any] = data.reduce(into: [:]) { result, x in
            result[x.key.rawValue] = x.value
        }
        session.sendMessage(dictionary, replyHandler: nil)
    }
}
