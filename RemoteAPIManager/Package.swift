// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteAPIManager",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RemoteAPIManager",
            targets: ["RemoteAPIManager"]),
    ],
    dependencies: [
        .package(name: "RemoteEndPoints", path: "../RemoteEndPoints"),
    ],
    targets: [
        .target(
            name: "RemoteAPIManager",
            dependencies: [
                .productItem(name: "RemoteEndPoints", package: "RemoteEndPoints", condition: .none),
            ]),
        .testTarget(
            name: "RemoteAPIManagerTests",
            dependencies: ["RemoteAPIManager"]),
    ]
)
