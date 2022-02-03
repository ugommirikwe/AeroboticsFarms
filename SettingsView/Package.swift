// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SettingsView",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SettingsView",
            targets: ["SettingsView"]),
    ],
    dependencies: [
        .package(name: "SettingsDataRepository", path: "../SettingsDataRepository"),
    ],
    targets: [
        .target(
            name: "SettingsView",
            dependencies: [
                .productItem(name: "SettingsDataRepository", package: "SettingsDataRepository", condition: .none),
            ]),
        .testTarget(
            name: "SettingsViewTests",
            dependencies: ["SettingsView"]),
    ]
)
