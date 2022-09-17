//
//  GrayTextField.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import SwiftUI

struct GrayTextField: View {
    @Binding var text: String
    var title: String
    var hint: String
    var isSecure: Bool = false
    var contentType: UITextContentType? = nil
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                if isSecure {
                    SecureField(hint, text: $text)
                        .textContentType(contentType)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.secondary)
                        )
                } else {
                    TextField(title, text: $text)
                        .textContentType(contentType)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 50)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.secondary)
                        )
                }
                
                Text(title)
                    .padding(.horizontal,5)
                    .frame(height: 15)
                    .background(.white)
                    .padding(.bottom, 50)
                    .padding(.horizontal, 15)
                    .foregroundColor(.secondary)
            }
        }
        
    }
}

struct GrayTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GrayTextField(text: .constant("test"), title: "test", hint: "this is a test", isSecure: true)
            GrayTextField(text: .constant("test"), title: "test", hint: "this is a test", isSecure: false)

        }
    }
}
