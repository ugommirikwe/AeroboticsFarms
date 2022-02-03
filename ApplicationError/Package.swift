// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApplicationError",
    products: [
        .library(
            name: "ApplicationError",
            targets: ["ApplicationError"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ApplicationError",
            dependencies: []),
        .testTarget(
            name: "ApplicationErrorTests",
            dependencies: ["ApplicationError"]),
    ]
)
