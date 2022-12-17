//
//  SettingsView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {
    @InjectedObject private var defaultsManager: UserDefaultManager
    @InjectedObject private var authVM: AuthViewModel
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        List {
            Section {
                Button {
                    if defaultsManager.isLoggedIn {
                        vm.isShowingLogoutAlert.toggle()
                    } else {
                        vm.isShowingAlert.toggle()
                    }
                } label: {
                    loginIconView
                }
                .confirmationDialog("Log in or register", isPresented: $vm.isShowingAlert) {
                    NavigationLink("Login") {
                        LoginView()
                    }
                    NavigationLink("Register") {
                        RegisterView()
                    }

                } message: {
                    Text("Log into an existing account or register")
                }
                .confirmationDialog("Logout", isPresented: $vm.isShowingLogoutAlert) {
                    Button(role: .destructive) {
                        authVM.logOut()
                    } label: {
                        Text("Yes")
                    }

                    Button("No") {
                        vm.isShowingLogoutAlert.toggle()
                    }
                } message: {
                    Text("Are you sure you want to log out?")
                }
            } footer: {
                if !defaultsManager.isLoggedIn {
                    Text("You can log in to keep your data between devices.\nYou can still use the app logged out.")
                } else {
                    Button {
                        vm.isShowingQRCode.toggle()
                    } label: {
                        Text("Share data quickly with a QR code!")
                            .font(.system(.footnote, design: .rounded))
                    }
                    .accessibilityLabel("Share data")
                    .accessibilityHint("Opens a QR code to share your data with someone else")
                }
            }

            Section("Units of measurements") {
                VStack {
                    liquidsPicker
                    LabelledDivider()
                    solidsPicker
                }
            }
            if !defaultsManager.sharingAccounts.isEmpty {
                Section {
                    ForEach(defaultsManager.sharingAccounts, id: \.self) { account in
                        HStack {
                            Text(account.email)
                            Spacer()
                            Button {
                                vm.toggleRemovingAlert(with: account.id)
                            } label: {
                                Image(systemName:"xmark.app")
                                    .resizable()
                                    .frame(width: 24,height: 24)
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                    }
                } header: {
                    Text("Sharing info with ")
                } footer: {
                    Text("You are sharing your data with these accounts, you can disable this at any point")
                }
                .transition(.scale)
            }
            Section {
                Group {
                    Button("Report a bug 🐛") {
                        if let url = vm.createEmailUrl() {
                            UIApplication.shared.open(url)
                        }
                    }
                    .accessibilityLabel("Report a bug")
                    Button("Privacy policy") {
                        if let url = URL(string: "https://www.babywize.app/privacypolicy/") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .font(.system(.body, design: .rounded))
            } header: {
                Text("Contact")
            } footer: {
                Text("We're always available at contact@babywize.app")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .alert("Are you sure you want to stop sharing with this account?",
               isPresented: $vm.isShowingRemoveAlert,
               actions: {
                   Button(role: .cancel) {
                       vm.turnOffRemovingAlert()
                   } label: {
                       Text("No")
                   }
                   Button(role: .destructive) {
                       vm.removeFromSharing()
                   } label: {
                       Text("Remove")
                   }
               })
        .overlay {
            if vm.isLoading {
                LoadingOverlay(isShowing: $vm.isLoading)
            }
        }
        .overlay {
            if vm.isShowingQRCode {
                ZStack {
                    Color.black.opacity(0.8)
                        .opacity(vm.isShowingQRCode ? 1 : 0)
                    qrImage
                }
                .onTapGesture {
                    vm.isShowingQRCode.toggle()
                }
                .ignoresSafeArea(.all)
            }
        }
        .animation(.easeInOut, value: defaultsManager.sharingAccounts.isEmpty)
        .animation(.easeInOut, value: vm.isShowingQRCode)
    }

    @ViewBuilder
    private var qrImage: some View {
        if defaultsManager.isLoggedIn,
           let email = defaultsManager.email ,
           let id = defaultsManager.userID,
           let image = vm.generateQRCode(id: id, email: email) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .aspectRatio(1*1, contentMode: .fit)
        } else {
            Text("Something went wrong, please try again or contact support")
        }
    }

    @ViewBuilder
    private var liquidsPicker: some View {
        let title = "Liquids"
        ViewThatFits {
            VStack(alignment: .leading) {
                Picker(title, selection: $defaultsManager.liquidUnits) {
                    ForEach(LiquidFeedUnits.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
            VStack {
                Text(title)
                Picker(title, selection: $defaultsManager.liquidUnits) {
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
            Picker(title, selection: $defaultsManager.solidUnits) {
                ForEach(SolidFeedUnits.allCases, id: \.self) {
                    Text($0.rawValue)
                }
                .pickerStyle(.segmented)
            }
            VStack {
                Text(title)
                Picker(title, selection: $defaultsManager.solidUnits) {
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
                    .foregroundStyle(defaultsManager.isLoggedIn ? Color.red.gradient : Color.blue.gradient)
                Text(defaultsManager.isLoggedIn ? "Log out" : "Log in or register!")
                    .foregroundColor(defaultsManager.isLoggedIn ? .red : nil)
            }
            VStack(alignment: .center) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 25)
                    .frame(maxWidth: 100)
                    .foregroundStyle(defaultsManager.isLoggedIn ? Color.red.gradient : Color.blue.gradient)
                Text(defaultsManager.isLoggedIn ? "Log out" : "Log in or register!")
                    .foregroundColor(defaultsManager.isLoggedIn ? .red : nil)
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
