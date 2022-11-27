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
    @State private var isSecureState = false
    var title: String
    var hint: String
    var isSecure = false { didSet { _isSecureState.wrappedValue = isSecure } }
    var contentType: UITextContentType?
    var isFocused: Bool
    var selectedColor = Color.blue
    var hasError = false
    var keyboardType: UIKeyboardType = .default
    var errorText = ""

    private var imageName: String {
        isSecureState ? "eye.slash" : "eye"
    }

    private var accentColor: Color {
        isFocused ? selectedColor : Color.secondary
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                ZStack(alignment: .trailing) {
                    VStack {
                        Group {
                            if isSecureState {
                                SecureField(hint, text: $text)
                            } else {
                                TextField(hint, text: $text)
                            }
                        }
                        .transition(.opacity)
                        .textContentType(contentType)
                        .keyboardType(keyboardType)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(hasError ? Color.red : accentColor))
                        if hasError {
                            Text(errorText)
                                .foregroundColor(.red)
                                .font(.system(size: 9, design: .rounded))
                                .lineLimit(2)
                        }
                    }

                    if isSecure {
                        Button {
                            isSecureState.toggle()
                        } label: {
                            Image(systemName: imageName)
                                .accentColor(.gray)
                        }
                        .padding(.trailing)
                        .padding(.bottom, hasError ? 14 : 0)
                    }
                }
                Text(title)
                    .padding(.horizontal, 5)
                    .frame(height: 15)
                    .background(.white)
                    .padding(.bottom, hasError ? 75 : 50)
                    .padding(.horizontal, 15)
                    .foregroundColor(hasError ? Color.red : accentColor)
            }
            .animation(.easeInOut, value: isSecureState)
        }
    }
}

// MARK: - GrayTextField_Previews
struct GrayTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GrayTextField(text: .constant("test"),
                          title: "test",
                          hint: "this is a test",
                          isSecure: true,
                          isFocused: true,
                          hasError: true,
                          errorText: "Test error")
            GrayTextField(text: .constant("test"),
                          title: "test",
                          hint: "this is a test",
                          isSecure: false,
                          isFocused: false)
        }
    }
}
