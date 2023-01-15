//
//  SettingsView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI
import StoreKit
import Models
import TipJar
import Managers

// MARK: - SettingsView
struct SettingsView: View {
    @EnvironmentObject private var store: TipManager
    @InjectedObject private var defaultsManager: UserDefaultManager
    @InjectedObject private var authVM: AuthViewModel
    @StateObject private var vm = SettingsViewModel()

    private let accentColour = Color(hex: "#5354EC")
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
                            .foregroundColor(accentColour)
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
                    Button("Tip jar 💸") {
                        vm.showTips.toggle()
                    }
                    .foregroundStyle(.blue.gradient)

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
                    if defaultsManager.isLoggedIn {
                        Button("Delete account") {
                            vm.isShowingDeleteAccountAlert = true
                        }
                    }
                }

                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppColours.errorGradient)
            } header: {
                Text("Contact")
            } footer: {
                Text("We're always available at contact@babywize.app")
                    .accentColor(accentColour)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .alert("Are you sure you want to delete your account? THIS CANNOT BE UNDONE",
               isPresented: $vm.isShowingDeleteAccountAlert) {
            Button(role: .cancel) {
                vm.isShowingDeleteAccountAlert = false
            } label: {
                Text("No")
            }
            Button(role: .destructive) {
                authVM.deleteAccountAndLogOut()
            } label: {
                Text("Remove")
            }
        }
        .alert("Are you sure you want to stop sharing with this account?",
               isPresented: $vm.isShowingRemoveAlert) {
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
        }
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
        .overlay(alignment: .bottom) {
            if vm.showThanks {
                thankYouScreen
            }
        }
        .overlay {
            if vm.showTips {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        vm.showTips.toggle()
                    }
                cardVw
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: vm.showTips)
        .animation(.spring(), value: vm.showThanks)
        .onChange(of: store.action) { action in
            if vm.handleTipAction(action) {
                store.reset()
            }
        }
        .alert(isPresented: $store.hasError, error: store.error) {}
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
                    .foregroundStyle(defaultsManager.isLoggedIn ? AppColours.errorGradient : AppColours.gradient)
                Text(defaultsManager.isLoggedIn ? "Log out" : "Log in or register!")
                    .foregroundStyle(defaultsManager.isLoggedIn ? Color.red.gradient : Color.blue.gradient)
            }
            VStack(alignment: .center) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 25)
                    .frame(maxWidth: 100)
                    .foregroundStyle(defaultsManager.isLoggedIn ? AppColours.errorGradient : AppColours.gradient)
                Text(defaultsManager.isLoggedIn ? "Log out" : "Log in or register!")
                    .foregroundStyle(defaultsManager.isLoggedIn ? AppColours.errorGradient : AppColours.gradient)
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
                .environmentObject(TipManager())
        }
    }
}

private extension SettingsView {
    @ViewBuilder
    var cardVw: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button {
                    vm.showTips.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .gray.opacity(0.2))
                }
            }

            Text("Enjoying the app so far?")
                .font(.system(.title2, design: .rounded).bold())
                .multilineTextAlignment(.center)

            Text("This app is made by one dad out of the UK, trying to help parents get by.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            ForEach(store.items) { item in
                configureProductVw(item)
            }
        }
        .padding(16)
        .background(Color("card-background"), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(8)
        .overlay(alignment: .top) {
            Image("BWSVG")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(width: 75, height: 75)
                .padding(6)
                .offset(y: -25)
        }
    }

    @ViewBuilder
    func configureProductVw(_ item: Product) -> some View {
        HStack {
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
            }

            Spacer()

            Button(item.displayPrice) {
                Task {
                    await store.purchase(item)
                }
            }
            .tint(.blue)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
        .padding(16)
        .background(Color("cell-background"),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    var thankYouScreen: some View {
        VStack(spacing: 8) {
            Text("Thank You 💕")
                .font(.system(.title2, design: .rounded).bold())
                .multilineTextAlignment(.center)

            Text("Your support means the world to me, thank you for supporting indie developers")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Button {
                vm.showThanks.toggle()
            } label: {
                Text("Close")
                    .font(.system(.title3, design: .rounded).bold())
                    .tint(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 10,
                                                            style: .continuous))
            }
        }
        .padding(16)
        .background(Color("card-background"), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
