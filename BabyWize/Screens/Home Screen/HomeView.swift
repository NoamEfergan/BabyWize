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
    case home, settings, newEntry, feed, sleep, detailInputLiquidFeed,detailInputSolidFeed, detailInputSleep, none
}

// MARK: - HomeView
struct HomeView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @Environment(\.dynamicTypeSize) var typeSize
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @State private var isShowingNewEntrySheet = false
    @State private var wantsToAddEntry = false
    @State private var iconRotation: Double = 0
    @InjectedObject private var defaultsManager: UserDefaultManager
    
    var minChartHeight: Double {
        defaultsManager.chartConfiguration == .joint ? 350 : 550
    }

    private var shouldShowSheet: Bool {
        switch typeSize {
        case .xSmall, .small, .medium, .large, .xLarge , .xxLarge:
            return true
        default:
            return false
        }
    }

    var body: some View {
        NavigationStack(path: $navigationVM.path) {
            ScrollView {
                VStack {
                    QuickInfoSection()
                        .shadow(radius: 0)
                        .padding()
                    HomeScreenCharts()
                        .frame(minHeight: minChartHeight)
                        .contentTransition(.interpolate)
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
                            .rotationEffect(.degrees(iconRotation))
                    }
                }
            }
            .navigationTitle("Baby Wize")
            .sheet(isPresented: $isShowingNewEntrySheet) {
                AddEntryView()
                    .presentationDetents([.fraction(0.4), .medium])
                    .onDisappear {
                        wantsToAddEntry = false
                    }
            }
            .onChange(of: wantsToAddEntry, perform: { newValue in
                iconRotation = newValue ? 45 : 0
                if shouldShowSheet {
                    isShowingNewEntrySheet = newValue
                } else {
                    newValue ? navigationVM.path.append(.newEntry) : navigationVM.path.removeAll()
                }
            })
            .navigationDestination(for: Screens.self, destination: handleScreensNavigation)
            .task {
                WidgetManager().setLatest()
            }
            .animation(.easeOut, value: iconRotation)
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
        case .detailInputLiquidFeed:
            InputDetailView(type: .liquidFeed)
                .navigationTitle("All liquid feeds")
        case .detailInputSolidFeed:
            InputDetailView(type: .solidFeed)
                .navigationTitle("All solid feeds")

        default:
            EmptyView()
        }
    }
}

// MARK: - HomeView_Previews
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NavigationViewModel())
    }
}
