//
//  SettingsView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedUnitOfFood: FeedUnits = .ml
    @AppStorage(Constants.preferredUnit.rawValue) private var savedUnit = ""
    var body: some View {
        List {
            Section("general") {
                Picker("Preferred unit of measurement ", selection: $selectedUnitOfFood) {
                    ForEach(FeedUnits.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .onChange(of: selectedUnitOfFood) { newValue in
            savedUnit = newValue.rawValue
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
