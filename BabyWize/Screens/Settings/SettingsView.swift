//
//  SettingsView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedUnitOfFood: FeedUnits = .ml
    @State private var isShowingAlert = false
    @State private var isShowingLogoutAlert = false
    @State private var isLoginViewShowing = false

    @AppStorage(Constants.preferredUnit.rawValue) private var savedUnit = ""
    @AppStorage(UserConstants.isLoggedIn) private var savedIsUserLoggedIn: Bool?
    @StateObject private var authVM = AuthViewModel()

    private var isLoggedIn: Bool {
        guard let savedIsUserLoggedIn else { return false }
        return savedIsUserLoggedIn
    }

    var body: some View {
        List {
            Section {
                Button {
                    if isLoggedIn {
                        isShowingLogoutAlert.toggle()
                    } else {
                        isShowingAlert.toggle()
                    }
                } label: {
                    loginIconView
                }
                .confirmationDialog("Log in or register", isPresented: $isShowingAlert) {
                    NavigationLink("Login") {
                        LoginView(vm: authVM)
                    }
                    NavigationLink("Register") {
                        RegisterView()
                    }

                } message: {
                    Text("Log into an existing account or register")
                }
                .confirmationDialog("Logout", isPresented: $isShowingLogoutAlert) {
                    Button(role: .destructive) {
                            authVM.logOut()
                    } label: {
                        Text("Yes")
                    }

                    Button("No") {
                        isShowingLogoutAlert.toggle()
                    }
                } message: {
                    Text("Are you sure you want to log out?")
                }
            } footer: {
                if !isLoggedIn {
                    Text("You can log in to keep your data between devices.\nYou can still use the app logged out.")
                }
            }

            Section("general") {
                Picker("Preferred unit of measurement ", selection: $selectedUnitOfFood) {
                    ForEach(FeedUnits.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .onChange(of: selectedUnitOfFood) { newValue in
            savedUnit = newValue.rawValue
        }
    }

    private var loginIconView: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25)
                .foregroundStyle(isLoggedIn ? Color.red.gradient : Color.blue.gradient)
            Text(isLoggedIn ? "Log out" : "Log in or register!")
                .foregroundColor(isLoggedIn ? .red : nil)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
