// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkMonitorUtil",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NetworkMonitorUtil",
            targets: ["NetworkMonitorUtil"]),
        .library(
            name: "NetworkMonitorUtilView",
            targets: ["NetworkMonitorUtilView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkMonitorUtil",
            dependencies: []),
        .testTarget(
            name: "NetworkMonitorUtilTests",
            dependencies: ["NetworkMonitorUtil"]),
        .target(
            name: "NetworkMonitorUtilView",
            dependencies: ["NetworkMonitorUtil"]),
        .testTarget(
            name: "NetworkMonitorUtilViewTests",
            dependencies: ["NetworkMonitorUtilView"]),
    ]
)
