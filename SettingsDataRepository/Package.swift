// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SettingsDataRepository",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SettingsDataRepository",
            targets: ["SettingsDataRepository"]),
    ],
    dependencies: [
        .package(name: "KeychainUtil", path: "../KeychainUtil"),
    ],
    targets: [
        .target(
            name: "SettingsDataRepository",
            dependencies: [
                .productItem(name: "KeychainUtil", package: "KeychainUtil", condition: .none),]),
        .testTarget(
            name: "SettingsDataRepositoryTests",
            dependencies: ["SettingsDataRepository"]),
    ]
)
