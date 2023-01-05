//
//  TestTipView.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/01/2023.
//

import SwiftUI
import StoreKit

// MARK: - ProductsListView
struct ProductsListView: View {
    @EnvironmentObject private var store: TipManager

    var body: some View {
        ForEach(store.items) { item in
            ProductView(item: item)
        }
    }
}

// MARK: - ProductView
struct ProductView: View {
    let item: Product
    var body: some View {
        HStack {
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
            }

            Spacer()

            Button(item.displayPrice) {
                // TODO: Handle purchase
            }
            .tint(.blue)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
    }
}

