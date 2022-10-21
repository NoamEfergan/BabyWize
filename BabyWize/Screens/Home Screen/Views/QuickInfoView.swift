//
//  QuickInfoView.swift
//  BabyWize
//
//  Created by Noam Efergan on 21/10/2022.
//

import SwiftUI

// MARK: - QuickInfoView

struct QuickInfoView: View {
    let color: Color
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
            Text(value)
                .font(.system(.title2))
                .bold()
        }
        .padding(.horizontal)
        .foregroundColor(.white)
        .frame(width: 160, height: 130)
        .background(RoundedRectangle(cornerRadius: 32, style: .continuous).foregroundColor(color))
    }
}

// MARK: - QuickInfoView_Previews

struct QuickInfoView_Previews: PreviewProvider {
    static var previews: some View {
        QuickInfoView(color: .purple, title: "Last Feed", value: "Non recorded")
    }
}
