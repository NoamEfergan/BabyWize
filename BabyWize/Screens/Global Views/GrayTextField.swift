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
    var onCommit: (() -> Void)? = nil
    var onChangeEdit: ((Bool) -> Void)? = nil

    private var imageName: String {
        isSecureState ? "eye.slash" : "eye"
    }

    private var accentColor: Color {
        isFocused ? selectedColor : Color.secondary
    }

    private var textShouldBeUp : Bool {
        if isFocused {
            return true
        } else {
            return !text.isEmpty
        }
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                ZStack(alignment: .trailing) {
                    VStack {
                        Group {
                            if isSecureState {
                                SecureField("", text: $text)
                            } else {
                                TextField("", text: $text)
                            }
                        }
                        .accessibilityElement()
                        .accessibilityLabel("\(title) Text field")
                        .accessibilityValue(text)
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
                                .font(.system(.footnote, design: .rounded))
                                .lineLimit(1)
                                .accessibilityLabel("\(title) Error label")
                                .accessibilityValue(errorText)
                        }
                    }

                    if isSecure {
                        Button {
                            isSecureState.toggle()
                        } label: {
                            Image(systemName: imageName)
                                .accentColor(.gray)
                        }
                        .accessibilityHidden(true)
                        .padding(.trailing)
                        .padding(.bottom, hasError ? 14 : 0)
                    }
                }
                Text(title)
                    .padding(.horizontal, 5)
                    .frame(height: 15)
                    .background(.white)
                    .padding(.bottom, hasError ? 17 : 0)
                    .offset(y: textShouldBeUp ? -25 : 0)
                    .padding(.horizontal, 15)
                    .foregroundColor(hasError ? Color.red : accentColor)
                    .accessibilityHidden(true)
            }
            .animation(.easeInOut, value: isSecureState)
            .animation(.easeInOut, value: isFocused)
        }
    }
}

// MARK: - GrayTextField_Previews
struct GrayTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GrayTextField(text: .constant(""),
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
