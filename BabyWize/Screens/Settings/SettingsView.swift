//
//  SettingsView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedUnitOfFood: FeedUnits = .ml
    @State private var isShowingAlert = false
    @AppStorage(Constants.preferredUnit.rawValue) private var savedUnit = ""
    var body: some View {
        List {
            Section {
                Button {
                    isShowingAlert.toggle()
                } label: {
                    loginIconView
                }
                .alert("Are you sure you want to log out?", isPresented: $isShowingAlert) {
                    VStack {
                        Button(role: .destructive) {
                            print("log out")
                        } label: {
                            Text("Log out")
                                .foregroundColor(.red)
                        }
                    }
                }
            } footer: {
//                if !realm.isLoggedIn {
//                    Text("You can log in to keep your data between devices.\nYou can still use the app logged out.")
//                }
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
//                .foregroundStyle(realm.isLoggedIn ? Color.red.gradient : Color.blue.gradient)
//            Text(realm.isLoggedIn ? "Log out" : "Log in ")
//                .foregroundColor(realm.isLoggedIn ? .red : nil)
        }
    }

    private var logOutAlert: Alert {
        Alert(
            title: Text("Are you sure you want to log out?"),
            primaryButton: .default(Text("Yes")),
            secondaryButton: .cancel()
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
