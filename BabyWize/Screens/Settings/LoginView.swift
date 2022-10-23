//
//  LoginView.swift
//  BabyWize
//
//  Created by Noam Efergan on 23/10/2022.
//

import SwiftUI

struct LoginView: View {
    private enum Textfields: Hashable {
        case email
        case password
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject private var vm = AuthViewModel()
    @State private var email = ""
    @State private var password = ""

    @State private var hasEmailError = false
    @State private var hasPasswordError = false

    @State private var isShowingRegistrationError = false

    @FocusState private var focusedField: Textfields?

    var body: some View {
        LoadingView(isShowing: $vm.isLoading, text: "Please wait while we create your account") {
            VStack(spacing: 30) {
                VStack {
                    GrayTextField(text: $email,
                                  title: "Email",
                                  hint: "Please enter your email",
                                  contentType: .emailAddress,
                                  isFocused: focusedField == .email,
                                  hasError: hasEmailError,
                                  keyboardType: .emailAddress,
                                  errorText: "Please enter a valid email")
                        .tag(Textfields.email)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            hasEmailError = !vm.validateEmail(email)
                            focusedField = .password
                        }

                    GrayTextField(text: $password,
                                  title: "Password",
                                  hint: "Please enter a password",
                                  isSecure: true,
                                  contentType: .newPassword,
                                  isFocused: focusedField == .password,
                                  hasError: hasPasswordError,
                                  errorText: "Password must be at least 8 characters long,\n and contain at least 1 capital letter and 1 number ")
                        .tag(Textfields.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit {
                            hasPasswordError = !vm.validatePassword(password)
                            focusedField = nil
                        }


                    Button("Login") {
                        hasPasswordError = !vm.validatePassword(password)
                        hasEmailError = !vm.validateEmail(email)
                        if !hasPasswordError, !hasEmailError {
                            Task {
                                if await vm.login(email: email, password: password) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.blue.gradient))
                }
                .animation(.easeInOut, value: focusedField)
                .padding(.horizontal)
                .onAppear {
                    focusedField = .email
                }
            }
            .alert("Whoops!\nsomething went wrong, please try again later", isPresented: $vm.hasError, actions: {
                Text("Please try again later")
            })
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
