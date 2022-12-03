//
//  LoadingOverlay.swift
//  BabyWize
//
//  Created by Noam Efergan on 26/11/2022.
//

import SwiftUI

struct LoadingOverlay: View {
    @Binding var isShowing: Bool
    var body: some View {
        ProgressView("Working on it....")
            .frame(width: 250,height: 250)
            .background(Color.secondary.colorInvert())
            .foregroundColor(Color.primary)
            .cornerRadius(20)
            .opacity(isShowing ? 1 : 0)
            .scaleEffect(isShowing ? 1 : 0.1)
            .animation(.easeInOut, value: isShowing)
    }
}
