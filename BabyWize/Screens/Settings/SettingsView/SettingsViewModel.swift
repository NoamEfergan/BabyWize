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
    @Published var isShowingAlert = false
    @Published var isShowingLogoutAlert = false
    @Published var isShowingQRCode = false
    private let qrImage = QrCodeImage()

    func generateQRCode(id: String, email: String) -> UIImage? {
        let dataString = "app.babywize://\(id)-\(email)"
        return qrImage.generateQRCode(from: dataString)
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
