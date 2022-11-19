//
//  AuthViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import FirebaseAuth
import Foundation

final class AuthViewModel: ObservableObject {
    @InjectedObject private var defaultsManager: UserDefaultManager
    @Published var isLoading = false
    @Published var isRegistering = false
    @Published var hasError = false
    @Published var errorMsg = ""
    
    @Published var didLogIn: Bool = false

    func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    /// Check's if the password contains at least one capital letter, one number, and is at least 8 chars long
    func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    @MainActor
    func createAccount(email: String, password: String) async -> Bool {
        isRegistering = true
        defer {
            isRegistering = false
        }
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            let credentials = EmailAuthProvider.credential(withEmail: email, password: password)
            try await authResult.user.link(with: credentials)
            print("Signed in as user \(authResult.user.uid), with email: \(email)")
            hasError = false
            defaultsManager.isLoggedIn = true
            defaultsManager.hasAccount = true
            defaultsManager.userID = authResult.user.uid
            try KeychainManager.setCredentials(.init(email: email, password: password))
            didLogIn = true
            return true
        } catch {
            print("There was an issue when trying to sign in: \(error)")
            hasError = true
            errorMsg = error.localizedDescription
            return false
        }
    }

    @MainActor
    @discardableResult
    func login(email: String, password: String, shouldSaveToKeychain: Bool = true) async -> String? {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            if shouldSaveToKeychain {
                try KeychainManager.setCredentials(.init(email: email, password: password))
            }
            let user = authDataResult.user
            defaultsManager.isLoggedIn = true
            defaultsManager.userID = user.uid
            defaultsManager.hasAccount = true
            hasError = false
            didLogIn = true
            print("Signed in as user \(user.uid), with email: \(user.email ?? "")")
            return user.uid
        } catch {
            print("There was an issue when trying to sign in: \(error.localizedDescription)")
            hasError = true
            errorMsg = error.localizedDescription
            return nil
        }
    }

    func logOut() {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            try Auth.auth().signOut()
            print("Signed out")
            hasError = false
            defaultsManager.isLoggedIn = false
            defaultsManager.userID = nil
            defaultsManager.hasAccount = false
            NotificationCenter.default.post(name: .didLogOut, object: nil)
            removeCredentialsFromKeychain()
            return
        } catch {
            print("There was an issue when trying to sign in: \(error)")
            hasError = true
            return
        }
    }

    private func removeCredentialsFromKeychain() {
        if let credentials = try? KeychainManager.fetchCredentials() {
            try? KeychainManager.removeCredentials(credentials)
        }
    }

    @MainActor
    func anonymousLogin() async -> String? {
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            print("UserID (login):" + authResult.user.uid)
            return authResult.user.uid
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
