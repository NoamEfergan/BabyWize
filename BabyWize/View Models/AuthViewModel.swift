//
//  AuthViewModel.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/09/2022.
//

import FirebaseAuth
import Foundation

final class AuthViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    
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
            isLoading = true
            defer {
                isLoading = false
            }
            do {
                let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let user = authDataResult.user
                print("Signed in as user \(user.uid), with email: \(user.email ?? "")")
                self.hasError = false
                UserDefaults.standard.set(true, forKey: UserConstants.isLoggedIn)
                return true
            } catch {
                print("There was an issue when trying to sign in: \(error)")
                self.hasError = true
                return false
            }
        }
    
    @MainActor
    func login(email: String, password: String) async -> Bool {
            isLoading = true
            defer {
                isLoading = false
            }
            do {
                let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
                let user = authDataResult.user
                print("Signed in as user \(user.uid), with email: \(user.email ?? "")")
                self.hasError = false
                return true
            } catch {
                print("There was an issue when trying to sign in: \(error)")
                self.hasError = true
                return false
            }
        }
}
