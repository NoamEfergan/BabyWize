//
//  GrayTextField.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import SwiftUI
import Models

// MARK: - GrayTextField
public struct GrayTextField: View {
    @Binding var text: String
    @State private var isSecureState = false
    var title: String
    var hint: String
    var isSecure: Bool { didSet { _isSecureState.wrappedValue = isSecure } }
    var contentType: UITextContentType?
    var isFocused: Bool
    var selectedColor: LinearGradient
    var hasError: Bool
    var keyboardType: UIKeyboardType
    var errorText: String
    var onCommit: (() -> Void)?
    var onChangeEdit: ((Bool) -> Void)?

    public init(text: Binding<String>,
                title: String,
                hint: String,
                isSecure: Bool = false ,
                contentType: UITextContentType?,
                isFocused: Bool,
                selectedColor: LinearGradient = AppColours.gradient,
                hasError: Bool = false,
                keyboardType: UIKeyboardType = .default,
                errorText: String = "",
                onCommit: (() -> ())? = nil,
                onChangeEdit: ((Bool) -> ())? = nil) {
        _text = text
        self.title = title
        self.hint = hint
        self.isSecure = isSecure
        self.contentType = contentType
        self.isFocused = isFocused
        self.selectedColor = selectedColor
        self.hasError = hasError
        self.keyboardType = keyboardType
        self.errorText = errorText
        self.onCommit = onCommit
        self.onChangeEdit = onChangeEdit
    }

    private var imageName: String {
        isSecureState ? "eye.slash" : "eye"
    }

    private var accentColor: LinearGradient {
        isFocused ? selectedColor : AppColours.secondary
    }

    private var textShouldBeUp : Bool {
        if isFocused {
            return true
        } else {
            return !text.isEmpty
        }
    }

    public var body: some View {
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
                            .stroke(hasError ? AppColours.errorGradient : AppColours.gradient))
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
                    .foregroundStyle(hasError ? AppColours.errorGradient: accentColor)
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
                          contentType: .emailAddress ,
                          isFocused: true,
                          hasError: true,
                          errorText: "Test error")
            GrayTextField(text: .constant("test"),
                          title: "test",
                          hint: "this is a test",
                          isSecure: false,
                          contentType: .password ,
                          isFocused: false)
        }
    }
}
