//
//  SettingsViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 26/11/2022.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - SettingsViewModel
final class SettingsViewModel: ObservableObject {
    @Inject private var firebaseManager: FirebaseManager
    @Published var isShowingAlert = false
    @Published var isShowingLogoutAlert = false
    @Published var isShowingQRCode = false
    @Published var isShowingRemoveAlert = false
    @Published var isLoading = false
    private let qrImage = QrCodeImage()
    private var idToRemove = ""

    func generateQRCode(id: String, email: String) -> UIImage? {
        let dataString = "app.babywize://\(id)-\(email)"
        return qrImage.generateQRCode(from: dataString)
    }

    func removeFromSharing() {
        isLoading = true
        firebaseManager.removeIdFromShared(idToRemove)
        isLoading = false
    }

    func toggleRemovingAlert(with id: String) {
        idToRemove = id
        isShowingRemoveAlert = true
    }

    func turnOffRemovingAlert() {
        idToRemove = ""
        isShowingRemoveAlert = false
    }
}

// MARK: - QrCodeImage
struct QrCodeImage {
    let context = CIContext()
    func generateQRCode(from text: String) -> UIImage {
        var qrImage = UIImage(systemName: "xmark.circle") ?? UIImage()
        let data = Data(text.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: 2, y: 2)

        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let image = context.createCGImage(outputImage,

                                                 from: outputImage.extent) {
                qrImage = UIImage(cgImage: image)
            }
        }

        return qrImage
    }
}
