//
//  LoginView.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import FirebaseAuth
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            GrayTextField(
                text: $email,
                title: "Email",
                hint: "Please enter your email",
                contentType: .emailAddress
            )
            GrayTextField(
                text: $password,
                title: "Password",
                hint: "Please enter a password",
                isSecure: true,
                contentType: .newPassword
            )
            
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
        .padding(.horizontal)
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
