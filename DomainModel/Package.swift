// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DomainModel",
    products: [
        .library(
            name: "DomainModel",
            targets: ["DomainModel"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DomainModel",
            dependencies: []),
        .testTarget(
            name: "DomainModelTests",
            dependencies: ["DomainModel"]),
    ]
)
