// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteEndPoints",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RemoteEndPoints",
            targets: ["RemoteEndPoints"]),
    ],
    dependencies: [
        .package(name: "ApplicationError", path: "../ApplicationError"),
        .package(name: "SettingsDataRepository", path: "../SettingsDataRepository"),
    ],
    targets: [
        .target(
            name: "RemoteEndPoints",
            dependencies: [
                .productItem(name: "ApplicationError", package: "ApplicationError", condition: .none),
                .productItem(name: "SettingsDataRepository", package: "SettingsDataRepository", condition: .none),
            ]),
        .testTarget(
            name: "RemoteEndPointsTests",
            dependencies: ["RemoteEndPoints"]),
    ]
)
