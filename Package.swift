// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "BabyWize",
                      platforms: [.iOS(.v16)],
                      products: [
                          .library(name: "Models",targets: ["Models"]),
                          .library(name: "TipJar",targets: ["TipJar"]),
                      ],
                      dependencies: [
                          .package(url: "https://github.com/Swinject/Swinject.git", .upToNextMajor(from: "2.8.1")),
                          .package(url: "https://github.com/peripheryapp/periphery", from: "2.0.0"),
                      ],
                      targets: [
                          .target(name: "Models",dependencies: ["Swinject"]),
                          .target(name: "TipJar",dependencies: []),
                      ])
