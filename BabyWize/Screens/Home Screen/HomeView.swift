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
    case home, settings, newEntry, feed, sleep, detailInputLiquidFeed,detailInputSolidFeed, detailInputNappy,
         detailInputSleep, none
}

// MARK: - HomeView
struct HomeView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @InjectedObject private var defaultsManager: UserDefaultManager
    @InjectedObject private var authVM: AuthViewModel
    @Environment(\.dynamicTypeSize) var typeSize
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject private var sharingVC = SharingViewModel()

    @State private var isShowingNewEntrySheet = false
    @State private var wantsToAddEntry = false
    @State private var iconRotation: Double = 0

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
            LoadingView(isShowing: $authVM.isLoading, text: "Signing you back in...") {
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
                .alert(sharingVC.acceptAlertTitle,
                       isPresented: $sharingVC.isShowingAcceptAlert,
                       actions: {
                           Button("Accept") {
                               sharingVC.didAcceptSharing()
                           }
                           Button(role: .cancel) {
                               sharingVC.isShowingAcceptAlert = false
                           } label: {
                               Text("No thanks")
                           }
                       })
                .alert(sharingVC.errorMsg, isPresented: $sharingVC.hasError,
                       actions: {
                           Button("Try again later") {
                               sharingVC.hasError = false
                           }
                       })
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
                .overlay {
                    if sharingVC.isLoading {
                        LoadingOverlay(isShowing: $sharingVC.isLoading)
                    }
                }
                .animation(.easeOut, value: iconRotation)
                .animation(.easeOut, value: sharingVC.isLoading)
                .onOpenURL { url in
                    if url.absoluteString.starts(with: "widget") {
                        wantsToAddEntry = true
                    }
                    if url.absoluteString.starts(with: "app.babywize") {
                        sharingVC.extractInfo(from: url)
                    }
                }
            }
        }
    }

    // app.babywize://MZhOgd8Hc8f8Japf7gmfzxHWzK63-1@3.com

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
        case .detailInputNappy:
            InputDetailView(type: .nappy)
                .navigationTitle("All nappy changes")

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
