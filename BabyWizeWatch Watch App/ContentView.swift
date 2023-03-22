//
//  ContentView.swift
//  BabyWizeWatch Watch App
//
//  Created by Noam Efergan on 21/03/2023.
//

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

// MARK: - ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
