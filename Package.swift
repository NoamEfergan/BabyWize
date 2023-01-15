// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "BabyWize",
                      platforms: [.iOS(.v16)],
                      products: [
                          .library(name: "Models",targets: ["Models"]),
                          .library(name: "TipJar",targets: ["TipJar"]),
                          .library(name: "Siri",targets: ["Siri"]),
                          .library(name: "Managers",targets: ["Managers"]),
                          .library(name: "SettingsView",targets: ["SettingsView"]),
                          .library(name: "GlobalViews",targets: ["GlobalViews"]),
                          .library(name: "EntryViews",targets: ["EntryViews"]),
                          .library(name: "AccessibleViews",targets: ["AccessibleViews"]),
                          .library(name: "InputDetailViews",targets: ["InputDetailViews"]),
                          .library(name: "ViewModels",targets: ["ViewModels"]),
                      ],
                      dependencies: [
                          .package(url: "https://github.com/Swinject/Swinject.git", .upToNextMajor(from: "2.8.1")),
                          .package(url: "https://github.com/peripheryapp/periphery", from: "2.0.0"),
                          .package(url: "https://github.com/firebase/firebase-ios-sdk.git",
                                   .upToNextMajor(from: "9.6.0")),
                          .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
                      ],
                      targets: [
                          .target(name: "Models",dependencies: ["Swinject"]),
                          .target(name: "TipJar",dependencies: []),
                          .target(name: "Siri",dependencies: ["Models", "Managers"]),
                          .target(name: "GlobalViews",dependencies: []),
                          .target(name: "EntryViews",
                                  dependencies: ["Models", "Managers", "AccessibleViews","ViewModels"]),
                          .target(name: "AccessibleViews",dependencies: []),
                          .target(name: "InputDetailViews",dependencies: ["Models", "Managers", "ViewModels"]),
                          .target(name: "ViewModels",dependencies: ["Models", "Managers"]),
                          .target(name: "SettingsView",dependencies: ["Models", "Managers", "GlobalViews"]),
                          .target(name: "Managers",dependencies: [
                              "Models",
                              .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                              .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                              .product(name: "Algorithms", package: "swift-algorithms"),
                          ]),
                      ])
