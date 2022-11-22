//
//  SharingViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/11/2022.
//

import Foundation
import SwiftUI

final class SharingViewModel: ObservableObject {
    @InjectedObject private var babyDataManager: BabyDataManager
    private let baseURL = "app.babywize://"
    private var id: String?
    @Published var isShowingAcceptAlert = false
    @Published var acceptAlertTitle = ""
    @Published var hasError = false
    @Published var isLoading = false

    func extractInfo(from url: URL) {
        let urlString = url.absoluteString
        let components = urlString.components(separatedBy: baseURL).last?.components(separatedBy: "-")
        let id = components?.first
        let email = components?.last
        self.id = id
        acceptAlertTitle = "\(email ?? "Someone") is inviting you to share data!"
        isShowingAcceptAlert = true
    }

    func didAcceptSharing() {
        isLoading = true
        guard let id else {
            hasError = true
            return
        }
        Task { [weak self ] in
            guard let self else { return }
            let success = await self.babyDataManager.firebaseManager.getSharedData(for: id)
            self.isLoading = false
            self.hasError = !success
        }
    }
}
