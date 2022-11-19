//
//  SettingsView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {
    @InjectedObject private var unitsManager: UserDefaultManager
    @State private var isShowingAlert = false
    @State private var isShowingLogoutAlert = false
    @State private var isLoginViewShowing = false

    @AppStorage(UserConstants.isLoggedIn) private var savedIsUserLoggedIn: Bool?
    @InjectedObject private var authVM: AuthViewModel

    private var isLoggedIn: Bool {
        guard let savedIsUserLoggedIn else {
            return false
        }
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
                        LoginView()
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

            Section("Units of messuremants") {
                VStack {
                    liquidsPicker
                    LabelledDivider()
                    solidsPicker
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }

    @ViewBuilder
    private var liquidsPicker: some View {
        let title = "Liquids"
        ViewThatFits {
            VStack(alignment: .leading) {
                Picker(title, selection: $unitsManager.liquidUnits) {
                    ForEach(LiquidFeedUnits.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
            VStack {
                Text(title)
                Picker(title, selection: $unitsManager.liquidUnits) {
                    ForEach(LiquidFeedUnits.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.automatic)
                .labelsHidden()
            }
        }
        .font(.system(.body, design: .rounded))
    }

    @ViewBuilder
    private var solidsPicker: some View {
        let title = "Solids"
        ViewThatFits {
            Picker(title, selection: $unitsManager.solidUnits) {
                ForEach(SolidFeedUnits.allCases, id: \.self) {
                    Text($0.rawValue)
                }
                .pickerStyle(.segmented)
            }
            VStack {
                Text(title)
                Picker(title, selection: $unitsManager.solidUnits) {
                    ForEach(SolidFeedUnits.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.automatic)
                .labelsHidden()
            }
        }
        .font(.system(.body, design: .rounded))
    }

    @ViewBuilder
    private var loginIconView: some View {
        ViewThatFits {
            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)
                    .foregroundStyle(isLoggedIn ? Color.red.gradient : Color.blue.gradient)
                Text(isLoggedIn ? "Log out" : "Log in or register!")
                    .foregroundColor(isLoggedIn ? .red : nil)
            }
            VStack(alignment: .center) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 25)
                    .frame(maxWidth: 100)
                    .foregroundStyle(isLoggedIn ? Color.red.gradient : Color.blue.gradient)
                Text(isLoggedIn ? "Log out" : "Log in or register!")
                    .foregroundColor(isLoggedIn ? .red : nil)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

// MARK: - SettingsView_Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
