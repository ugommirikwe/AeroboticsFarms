// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FarmDataSourceRemote",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FarmDataSourceRemote",
            targets: ["FarmDataSourceRemote"]),
    ],
    dependencies: [
        .package(name: "DomainModel", path: "../DomainModel"),
        .package(name: "ApplicationError", path: "../ApplicationError"),
        .package(name: "RemoteEndPoints", path: "../RemoteEndPoints"),
        .package(name: "RemoteAPIManager", path: "../RemoteAPIManager"),
    ],
    targets: [
        .target(
            name: "FarmDataSourceRemote",
            dependencies: [
                .productItem(name: "DomainModel", package: "DomainModel", condition: .none),
                .productItem(name: "ApplicationError", package: "ApplicationError", condition: .none),
                .productItem(name: "RemoteEndPoints", package: "RemoteEndPoints", condition: .none),
                .productItem(name: "RemoteAPIManager", package: "RemoteAPIManager", condition: .none),
            ]),
        .testTarget(
            name: "FarmDataSourceRemoteTests",
            dependencies: ["FarmDataSourceRemote"]),
    ]
)
