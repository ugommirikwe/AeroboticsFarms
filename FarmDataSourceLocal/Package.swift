// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FarmDataSourceLocal",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FarmDataSourceLocal",
            targets: ["FarmDataSourceLocal"]),
    ],
    dependencies: [
        .package(name: "DomainModel", path: "../DomainModel"),
        .package(name: "ApplicationError", path: "../ApplicationError"),
    ],
    targets: [
        .target(
            name: "FarmDataSourceLocal",
            dependencies: [
                .productItem(name: "DomainModel", package: "DomainModel", condition: .none),
                .productItem(name: "ApplicationError", package: "ApplicationError", condition: .none),
            ]),
        .testTarget(
            name: "FarmDataSourceLocalTests",
            dependencies: ["FarmDataSourceLocal"]),
    ]
)
