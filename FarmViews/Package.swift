// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FarmViews",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FarmViews",
            targets: ["FarmViews"]),
    ],
    dependencies: [
        .package(name: "NetworkMonitorUtil", path: "../NetworkMonitorUtil"),
        .package(name: "ApplicationError", path: "../ApplicationError"),
        .package(name: "DomainModel", path: "../DomainModel"),
        .package(name: "DataRepository", path: "../DataRepository"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FarmViews",
            dependencies: [
                .productItem(name: "NetworkMonitorUtil", package: "NetworkMonitorUtil", condition: .none),
                .productItem(name: "NetworkMonitorUtilView", package: "NetworkMonitorUtil", condition: .none),
                .productItem(name: "ApplicationError", package: "ApplicationError", condition: .none),
                .productItem(name: "DomainModel", package: "DomainModel", condition: .none),
                .productItem(name: "DataRepository", package: "DataRepository", condition: .none),
            ]),
        .testTarget(
            name: "FarmViewsTests",
            dependencies: ["FarmViews"]),
    ]
)
