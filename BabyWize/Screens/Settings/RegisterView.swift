//
//  RegisterView.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import SwiftUI

// MARK: - RegisterView

struct RegisterView: View {
    private enum Textfields: Hashable {
        case email
        case password
        case rePassword
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject private var vm = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var rePassword = ""

    @State private var hasEmailError = false
    @State private var hasPasswordError = false
    @State private var hasRePasswordError = false

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
                            focusedField = .rePassword
                        }

                    GrayTextField(text: $rePassword,
                                  title: "Re-Enter Password",
                                  hint: "Please re-enter the same password",
                                  isSecure: true,
                                  contentType: .newPassword,
                                  isFocused: focusedField == .rePassword,
                                  hasError: hasRePasswordError,
                                  errorText: "Both passwords must match")
                        .tag(Textfields.rePassword)
                        .focused($focusedField, equals: .rePassword)
                        .submitLabel(.done)
                        .onSubmit {
                            hasRePasswordError = password != rePassword
                            focusedField = .none
                        }

                    Button("Create account") {
                        hasPasswordError = !vm.validatePassword(password)
                        hasEmailError = !vm.validateEmail(email)
                        hasRePasswordError = password != rePassword
                        if !hasPasswordError, !hasEmailError, !hasRePasswordError {
                            Task {
                                if await vm.createAccount(email: email, password: password) {
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
                Button("Already have an account? Click here!") {
                    print("here")
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
                    case .password:
                        Button("Next") {
                            focusedField = .rePassword
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

// MARK: - LoginView_Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
