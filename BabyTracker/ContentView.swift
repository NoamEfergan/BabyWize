//
//  ContentView.swift
//  BabyTracker
//
//  Created by Noam Efergan on 17/07/2022.
//

import Charts
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("recent info") {
                    LabeledContent("Last Feed", value: "180 ml")
                    LabeledContent("Last Nappy change", value: "12:43 pm")
                    LabeledContent("Last Sleep", value: "1 hr 07 mins")
                }
                HomeScreenSections()
            }
            .toolbar {
                Button {
                    print("add something")
                } label: {
                    Image(systemName: "plus.circle")
                }
            }.navigationTitle("Baby Tracker")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
