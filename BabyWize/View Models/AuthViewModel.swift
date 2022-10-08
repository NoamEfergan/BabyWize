//
//  AuthViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import FirebaseAuth
import Foundation

final class AuthViewModel: ObservableObject {
    func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    @MainActor
    func createAccount(email: String, password: String) async -> GenericNetworkResponse {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = authDataResult.user

            print("Signed in as user \(user.uid), with email: \(user.email ?? "")")
            return .succsess
        } catch {
            print("There was an issue when trying to sign in: \(error)")
            return .fail(msg: error.localizedDescription)
        }
    }
}
