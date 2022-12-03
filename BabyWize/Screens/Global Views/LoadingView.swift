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
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                ProgressView(text)
                    .frame(width: geometry.size.width / 2,
                           height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
                    .scaleEffect(self.isShowing ? 1 : 0.1)
                    .animation(.easeInOut, value: isShowing)
            }
        }
    }
}
