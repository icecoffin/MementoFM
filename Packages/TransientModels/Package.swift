// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransientModels",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TransientModels",
            targets: ["TransientModels"]
        )
    ],
    targets: [
        .target(
            name: "TransientModels",
            dependencies: []
        )
    ]
)
