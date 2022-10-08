//
//  RegisterView.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import FirebaseAuth
import SwiftUI

struct RegisterView: View {
    private enum Textfields: Hashable {
        case email
        case password
    }

    @StateObject private var vm = AuthViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var hasEmailError: Bool = false
    @FocusState private var focusedField: Textfields?

    var body: some View {
        VStack(spacing: 30) {
            VStack {
                VStack(alignment: .leading, spacing: 3) {
                    GrayTextField(
                        text: $email,
                        title: "Email",
                        hint: "Please enter your email",
                        contentType: .emailAddress,
                        isFocused: focusedField == .email,
                        hasError: hasEmailError,
                        keyboardType: .emailAddress
                    )
                    .tag(Textfields.email)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        hasEmailError = !vm.validateEmail(email)
                        focusedField = .password
                    }
                    if hasEmailError {
                        Text("Please enter a valid email")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                GrayTextField(
                    text: $password,
                    title: "Password",
                    hint: "Please enter a password",
                    isSecure: true,
                    contentType: .newPassword,
                    isFocused: focusedField == .password
                )
                .tag(Textfields.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = .none
                }

                Button("Create account") {
                    print("Create account")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.blue.gradient)
                )
            }
            .animation(.easeInOut, value: focusedField)
            .padding(.horizontal)
            .onAppear {
                focusedField = .email
            }
            Button("Already have an account? Click here!") {
                print("here")
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                switch focusedField {
                case .email:
                    Button("Next") {
                        focusedField = .password
                    }
                default:
                    Button("Done") {
                        focusedField = nil
                    }
                }

            }
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
