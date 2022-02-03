// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataRepository",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "DataRepository",
            targets: ["DataRepository"]),
    ],
    dependencies: [
        .package(name: "NetworkMonitorUtil", path: "../NetworkMonitorUtil"),
        .package(name: "ApplicationError", path: "../ApplicationError"),
        .package(name: "DomainModel", path: "../DomainModel"),
        .package(name: "FarmDataSourceRemote", path: "../FarmDataSourceRemote"),
        .package(name: "FarmDataSourceLocal", path: "../FarmDataSourceLocal"),
    ],
    targets: [
        .target(
            name: "DataRepository",
            dependencies: [
                .productItem(name: "NetworkMonitorUtil", package: "NetworkMonitorUtil", condition: .none),
                .productItem(name: "ApplicationError", package: "ApplicationError", condition: .none),
                .productItem(name: "DomainModel", package: "DomainModel", condition: .none),
                .productItem(name: "FarmDataSourceRemote", package: "FarmDataSourceRemote", condition: .none),
                .productItem(name: "FarmDataSourceLocal", package: "FarmDataSourceLocal", condition: .none),
            ]),
        .testTarget(
            name: "DataRepositoryTests",
            dependencies: ["DataRepository"]),
    ]
)
