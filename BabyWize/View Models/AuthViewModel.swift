//
//  AuthViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import Network
import FirebaseAuth
import Foundation

final class AuthViewModel: ObservableObject {
    @InjectedObject private var defaultsManager: UserDefaultManager
    @Published var isLoading = false
    @Published var isRegistering = false
    @Published var hasError = false
    @Published var errorMsg = ""

    @Published var didLogIn = false
    @Published var didRegister: String?
    @Published var didDeleteAccount: String?
    let monitor = NWPathMonitor()

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
            defaultsManager.signIn(with: authResult.user.uid, email: email)
            try KeychainManager.setCredentials(.init(email: email, password: password))
            didLogIn = true
            didRegister = authResult.user.uid
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
                addCredentialsToKeychain(email: email, password: password)
            }
            let user = authDataResult.user
            defaultsManager.signIn(with: user.uid, email: email)
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

    func deleteAccountAndLogOut() {
        guard let userID = defaultsManager.userID else {
            return
        }
        Auth.auth().currentUser?.delete()
        didDeleteAccount = userID
        logOut()
    }

    func logOut() {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            try Auth.auth().signOut()
            hasError = false
            defaultsManager.logOut()
            NotificationCenter.default.post(name: .didLogOut, object: nil)
            removeCredentialsFromKeychain()
            print("Signed out")
            return
        } catch {
            print("There was an issue when trying to sign in: \(error)")
            hasError = true
            return
        }
    }

    // MARK: - Private methods

    private func addCredentialsToKeychain(email: String, password: String) {
        Task.detached(priority: .background) {
            let newCredentials = KeychainManager.Credentials(email: email, password: password)
            do {
                _ = try KeychainManager.fetchCredentials()
                try KeychainManager.updateCredentials(newCredentials)
            }
            catch {
                try? KeychainManager.setCredentials(newCredentials)
            }
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
            print("UserID (login):" + authResult.user.uid + " Signed in anonymously")
            return authResult.user.uid
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
