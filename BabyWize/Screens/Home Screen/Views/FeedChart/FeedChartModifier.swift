//
//  FeedChartModifier.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/03/2023.
//

import Foundation
import SwiftUI

// MARK: - ChartModifier
struct ChartModifier: ViewModifier {
    let plotWidth: CGFloat
    func body(content: Content) -> some View {
        content
            .chartPlotStyle(content: { plotArea in
                plotArea.frame(width: plotWidth)
            })
            .frame(maxHeight: .greatestFiniteMagnitude)
            .frame(maxWidth: .greatestFiniteMagnitude)
            .padding()
    }
}

extension View {
    func feedChartModifier(plotWidth: CGFloat) -> some View {
        modifier(ChartModifier(plotWidth: plotWidth))
    }
}
