//
//  GrayTextField.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import SwiftUI

// MARK: - GrayTextField

struct GrayTextField: View {
    @Binding var text: String
    var title: String
    var hint: String
    var isSecure = false
    var contentType: UITextContentType? = nil
    var isFocused: Bool
    var selectedColor = Color.blue
    var hasError: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        let accentColor = isFocused ? selectedColor : Color.secondary
        VStack {
            ZStack(alignment: .leading) {
                if isSecure {
                    SecureField(hint, text: $text)
                        .textContentType(contentType)
                        .keyboardType(keyboardType)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(hasError ? Color.red : accentColor))
                } else {
                    TextField(title, text: $text)
                        .textContentType(contentType)
                        .keyboardType(keyboardType)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(hasError ? Color.red : accentColor))
                }

                Text(title)
                    .padding(.horizontal, 5)
                    .frame(height: 15)
                    .background(.white)
                    .padding(.bottom, 50)
                    .padding(.horizontal, 15)
                    .foregroundColor(hasError ? Color.red : accentColor)
            }
        }
    }
}

// MARK: - GrayTextField_Previews

struct GrayTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GrayTextField(
                text: .constant("test"),
                title: "test",
                hint: "this is a test",
                isSecure: true,
                isFocused: true
            )
            GrayTextField(
                text: .constant("test"),
                title: "test",
                hint: "this is a test",
                isSecure: false,
                isFocused: false
            )
        }
    }
}
