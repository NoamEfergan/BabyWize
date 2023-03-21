//
//  LoadingView.swift
//  BabyWize
//
//  Created by Noam Efergan on 09/10/2022.
//

import SwiftUI

// MARK: - LoadingView

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var text: String
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                content()
                    .disabled(isShowing)
                    .blur(radius: isShowing ? 3 : 0)

                ProgressView(text)
                    .frame(width: geometry.size.width / 2,
                           height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(isShowing ? 1 : 0)
                    .scaleEffect(isShowing ? 1 : 0.1)
                    .animation(.easeInOut, value: isShowing)
            }
        }
    }
}
