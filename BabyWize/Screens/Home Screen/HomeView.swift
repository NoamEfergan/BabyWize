//
//  HomeView.swift
//  BabyWize
//
//  Created by Noam Efergan on 17/07/2022.
//

import Charts
import SwiftUI
import StoreKit
import Models
import Managers

// MARK: - Screens
enum Screens: String {
    case home, settings, newEntry, feed, sleep, detailInputLiquidFeed,detailInputSolidFeed, detailInputNappy,
         detailInputSleep,detailInputBreastFeed , none
}

// MARK: - HomeView
struct HomeView: View {
    @InjectedObject private var dataManager: BabyDataManager
    @InjectedObject private var defaultsManager: UserDefaultManager
    @InjectedObject private var authVM: AuthViewModel
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject private var sharingVC = SharingViewModel()
    @StateObject private var addEntryViewVM = AddEntryViewVM()

    @State private var isShowingNewEntrySheet = false
    @State private var wantsToAddEntry = false
    @State private var iconRotation: Double = 0

    var minChartHeight: Double {
        let hasBothType = !dataManager.feedData.isEmpty && !dataManager.breastFeedData.isEmpty
        let minJoint: Double = hasBothType ? 550 : 350
        let minSeparate: Double = hasBothType ? 750 : 550
        return defaultsManager.chartConfiguration == .joint ? minJoint : minSeparate
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
                                .foregroundStyle(AppColours.tintPurple.gradient)
                        }
                        .accessibilityRemoveTraits(.isImage)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Settings")
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            wantsToAddEntry.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(AppColours.tintPurple.gradient)
                                .rotationEffect(.degrees(iconRotation))
                        }
                    }
                }
                .navigationTitle("Baby Wize")
                .alert(sharingVC.acceptAlertTitle,
                       isPresented: $sharingVC.isShowingAcceptAlert) {
                    Button("Accept") {
                        sharingVC.didAcceptSharing()
                    }
                    Button(role: .cancel) {
                        sharingVC.isShowingAcceptAlert = false
                    } label: {
                        Text("No thanks")
                    }
                }
                .alert(sharingVC.errorMsg, isPresented: $sharingVC.hasError) {
                    Button("Try again later") {
                        sharingVC.hasError = false
                    }
                }
                .alert(authVM.errorMsg, isPresented: $authVM.hasError) {
                    Button("OK") {
                        authVM.hasError = false
                    }
                }
                .sheet(isPresented: $isShowingNewEntrySheet) {
                    AddEntryView(vm: addEntryViewVM)
                        .presentationDetents([.fraction(0.45), .medium])
                        .onDisappear {
                            wantsToAddEntry = false
                        }
                }
                .onChange(of: wantsToAddEntry) { newValue in
                    iconRotation = newValue ? 45 : 0
                    if shouldShowSheet {
                        isShowingNewEntrySheet = newValue
                    } else {
                        newValue ? navigationVM.path.append(.newEntry) : navigationVM.path.removeAll()
                    }
                }
                .navigationDestination(for: Screens.self, destination: handleScreensNavigation)
                .task {
                    WidgetManager().setLatest()
                }
                .onAppear {
                    if getShouldRequestReview() {
                        requestReview()
                        UserDefaults.standard.set(true, forKey: UserConstants.hasAskedForReview)
                    }
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
                        if url.absoluteString.contains("openSleep") {
                            addEntryViewVM.entryType = .sleep
                        } else if url.absoluteString.contains("openFeed") {
                            addEntryViewVM.entryType = .breastFeed
                        }
                    }
                    if url.absoluteString.starts(with: "app.babywize") {
                        sharingVC.extractInfo(from: url)
                    }
                }
            }
        }
        .tint(AppColours.tintPurple)
    }

    // MARK: - Navigation

    @ViewBuilder
    private func handleScreensNavigation(_ screen: Screens) -> some View {
        switch screen {
        case .settings:
            SettingsView()
        case .newEntry:
            AddEntryView(vm: addEntryViewVM)
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
        case .detailInputBreastFeed:
            InputDetailView(type: .breastFeed)
                .navigationTitle("All breast feeds")

        default:
            EmptyView()
        }
    }

    // MARK: - Private methods


    private func setInitialDownloadDate() {
        if UserDefaults.standard.object(forKey: UserConstants.initialInstallDate) as? Date == nil {
            UserDefaults.standard.set(Date.now, forKey: UserConstants.initialInstallDate)
        }
    }

    private func getShouldRequestReview() -> Bool {
        guard let initialInstallDate = UserDefaults.standard.object(forKey: UserConstants.initialInstallDate) as? Date
        else {
            setInitialDownloadDate()
            return false
        }
        let hasAskedForeReview = UserDefaults.standard.bool(forKey: UserConstants.hasAskedForReview)
        if hasAskedForeReview {
            return false
        } else {
            return initialInstallDate.timeIntervalSinceNow.hour > 72
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
