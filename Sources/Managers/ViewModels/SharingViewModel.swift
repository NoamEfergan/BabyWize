//
//  SharingViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/11/2022.
//

import Foundation
import SwiftUI
import Models

public final class SharingViewModel: ObservableObject {
    @InjectedObject private var defaultsManager: UserDefaultManager
    @Inject private var firebaseManager: FirebaseManager
    private let baseURL = "app.babywize://"
    private var id: String?
    private var email: String?
    @Published public var isShowingAcceptAlert = false
    @Published public var acceptAlertTitle = ""
    @Published public var hasError = false
    @Published public var isLoading = false
    @Published public var errorMsg = ""

    public init() {}

    public func extractInfo(from url: URL) {
        let urlString = url.absoluteString
        let components = urlString.components(separatedBy: baseURL).last?.components(separatedBy: "-")
        let id = components?.first
        let email = components?.last
        self.id = id
        self.email = email
        acceptAlertTitle = "\(email ?? "Someone") is inviting you to share data!"
        isShowingAcceptAlert = true
    }

    public func didAcceptSharing() {
        guard defaultsManager.email != nil else {
            hasError = true
            errorMsg = "You will need to create an account to share data"
            return
        }
        isLoading = true
        guard let id, let email else {
            hasError = true
            errorMsg = "Whoops!\nsomething went wrong there, please try again!"
            return
        }
        Task { [weak self] in
            guard let self else {
                return
            }
            let success = await firebaseManager.getSharedData(for: id, email: email)
            self.isLoading = false
            self.hasError = !success
        }
    }
}
