// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyProviderContainer",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "DependencyProviderContainer",
            targets: ["DependencyProviderContainer"]),
    ],
    dependencies: [
        .package(name: "NetworkMonitorUtil", path: "../NetworkMonitorUtil"),
        .package(name: "ApplicationError", path: "../ApplicationError"),
        .package(name: "DomainModel", path: "../DomainModel"),
        .package(name: "RemoteAPIManager", path: "../RemoteAPIManager"),
        .package(name: "FarmDataSourceRemote", path: "../FarmDataSourceRemote"),
        .package(name: "FarmDataSourceLocal", path: "../FarmDataSourceLocal"),
        .package(name: "DataRepository", path: "../DataRepository"),
        .package(name: "FarmViews", path: "../FarmViews"),
        .package(name: "KeychainUtil", path: "../KeychainUtil"),
        .package(name: "SettingsDataRepository", path: "../SettingsDataRepository"),
        .package(name: "SettingsView", path: "../SettingsView"),
    ],
    targets: [
        .target(
            name: "DependencyProviderContainer",
            dependencies: [
                .productItem(name: "NetworkMonitorUtil", package: "NetworkMonitorUtil", condition: .none),
                .productItem(name: "ApplicationError", package: "ApplicationError", condition: .none),
                .productItem(name: "DomainModel", package: "DomainModel", condition: .none),
                .productItem(name: "RemoteAPIManager", package: "RemoteAPIManager", condition: .none),
                .productItem(name: "FarmDataSourceRemote", package: "FarmDataSourceRemote", condition: .none),
                .productItem(name: "FarmDataSourceLocal", package: "FarmDataSourceLocal", condition: .none),
                .productItem(name: "DataRepository", package: "DataRepository", condition: .none),
                .productItem(name: "FarmViews", package: "FarmViews", condition: .none),
                .productItem(name: "KeychainUtil", package: "KeychainUtil", condition: .none),
                .productItem(name: "SettingsDataRepository", package: "DataRepository", condition: .none),
                .productItem(name: "SettingsView", package: "SettingsView", condition: .none),
            ]),
        .testTarget(
            name: "DependencyProviderContainerTests",
            dependencies: ["DependencyProviderContainer"]),
    ]
)
