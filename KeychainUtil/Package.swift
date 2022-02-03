// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeychainUtil",
    products: [
        .library(
            name: "KeychainUtil",
            targets: ["KeychainUtil"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "KeychainUtil",
            dependencies: []),
        .testTarget(
            name: "KeychainUtilTests",
            dependencies: ["KeychainUtil"]),
    ]
)
