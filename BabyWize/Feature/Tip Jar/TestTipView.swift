//
//  TestTipView.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/01/2023.
//

import SwiftUI
import StoreKit

// MARK: - TestView
struct TestView: View {
    @State private var myProduct: Product?

    var body: some View {
        VStack {
            Text("Product Info")
            Text(myProduct?.displayName ?? "")
            Text(myProduct?.description ?? "")
            Text(myProduct?.displayPrice ?? "")
            Text(myProduct?.price.description ?? "")
        }
        .task {
            myProduct = try? await Product.products(for: ["app.babywize.tinyTip"]).first
        }
    }
}

// MARK: - TestView_Previews
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
