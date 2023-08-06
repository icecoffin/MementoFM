// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PersistenceInterface",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PersistenceInterface",
            targets: ["PersistenceInterface"]
        )
    ],
    targets: [
        .target(
            name: "PersistenceInterface",
            dependencies: []),
        .testTarget(
            name: "PersistenceInterfaceTests",
            dependencies: ["PersistenceInterface"]
        )
    ]
)
