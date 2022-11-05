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
    case home, settings, newEntry, feed, sleep, detailInputFeed, detailInputSleep, none
}

// MARK: - HomeView
struct HomeView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @Environment(\.dynamicTypeSize) var typeSize
    @State private var path: [Screens] = []
    @State private var isShowingNewEntrySheet = false
    @State private var wantsToAddEntry = false
    @State private var isShowingSettings = false

    private var shouldShowSheet: Bool {
        switch typeSize {
        case .xSmall, .small, .medium, .large, .xLarge , .xxLarge:
            return true
        default:
            return false
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack {
                    QuickInfoSection()
                        .shadow(radius: 0)
                        .padding()
                    HomeScreenCharts()
                        .frame(minHeight: 350)
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
                        wantsToAddEntry.toggle()
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
                    .presentationDetents([.height(270)])
                    .onDisappear {
                        wantsToAddEntry = false
                    }
            }
            .onChange(of: wantsToAddEntry, perform: { newValue in
                if shouldShowSheet {
                    isShowingNewEntrySheet = newValue
                } else {
                    newValue ? path.append(.newEntry) : path.removeAll()
                }
            })
            .navigationDestination(for: Screens.self, destination: handleScreensNavigation)
            .task {
                WidgetManager().setLatest()
            }
            .onOpenURL { _ in
                // TODO: Handle more deep links!
                wantsToAddEntry = true
            }
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func handleScreensNavigation(_ screen: Screens) -> some View {
        switch screen {
        case .settings:
            SettingsView()
        case .newEntry:
            AddEntryView()
                .onDisappear {
                    wantsToAddEntry = false
                }
        case .feed, .sleep:
            InfoView(vm: .init(screen: screen))
        case .detailInputSleep:
            InputDetailView(type: .sleep)
                .navigationTitle("All sleeps")
        case .detailInputFeed:
            InputDetailView(type: .feed)
                .navigationTitle("All feeds")
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
