//
//  HomeView.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//

import Charts
import SwiftUI

// MARK: - Screens

enum Screens: String {
    case home, settings, newEntry
}

// MARK: - InfoScreens

enum InfoScreens: String {
    case feed, sleep, detailInputFeed, detailInputSleep, none
}

// MARK: - HomeView

struct HomeView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @State private var path: [Screens] = []
    @State private var isShowingNewEntrySheet = false
    @State private var isShowingSettings = false
    @StateObject private var entryVM = EntryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    QuickInfoSection()
                        .shadow(radius: 0)
                        .padding()
                    HomeScreenCharts()
                        .frame(height: 350)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(value: Screens.settings) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.secondary)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isShowingNewEntrySheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Baby Wize")
            .sheet(isPresented: $isShowingNewEntrySheet) {
                AddEntryView()
                    .environmentObject(entryVM)
                    .presentationDetents([.height(270)])
            }
            .navigationDestination(for: Screens.self, destination: handleScreensNavigation)
            .navigationDestination(for: InfoScreens.self, destination: handleInfoNavigation)
            .task {
                WidgetManager().setLatest()
            }
            .onOpenURL { _ in
                // TODO: Handle more deep links!
                isShowingNewEntrySheet = true
            }
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func handleInfoNavigation(_ screen: InfoScreens) -> some View {
        switch screen {
        case .feed, .sleep:
            InfoView(vm: .init(screen: screen))
        case .detailInputSleep:
            InputDetailView(type: .sleep)
                .navigationTitle("All sleeps")
                .environmentObject(entryVM)
        case .detailInputFeed:
            InputDetailView(type: .feed)
                .navigationTitle("All feeds")
                .environmentObject(entryVM)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func handleScreensNavigation(_ screen: Screens) -> some View {
        switch screen {
        case .settings:
            SettingsView()
        default:
            EmptyView()
        }
    }
}

// MARK: - HomeView_Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
