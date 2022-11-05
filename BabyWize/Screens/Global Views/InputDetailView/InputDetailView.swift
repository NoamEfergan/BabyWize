//
//  InputDetailView.swift
//  BabyWize
//
//  Created by Noam Efergan on 19/07/2022.
//

import SwiftUI

// MARK: - InputDetailView
struct InputDetailView: View {
    let type: EntryType
    @InjectedObject private var dataManager: BabyDataManager
    @State private var editMode = EditMode.inactive
    @State private var isShowingEntryView = false

    var body: some View {
        Group {
            switch type {
            case .feed:
                FeedInputDetailView()
            case .sleep:
                SleepInputDetailView()
            case .nappy:
                NappyInputDetailView()
            }
        }
        .environment(\.editMode, $editMode)
    }
}

// MARK: - InputDetailView_Previews
struct InputDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InputDetailView(type: .feed)
        }
        NavigationStack {
            InputDetailView(type: .sleep)
        }
        NavigationStack {
            InputDetailView(type: .nappy)
        }
    }
}
