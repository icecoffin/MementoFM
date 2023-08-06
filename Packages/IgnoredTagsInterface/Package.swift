// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IgnoredTagsInterface",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "IgnoredTagsInterface",
            targets: ["IgnoredTagsInterface"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../SharedServicesInterface")
    ],
    targets: [
        .target(
            name: "IgnoredTagsInterface",
            dependencies: [
                "Core",
                "SharedServicesInterface"
            ]
        )
    ]
)
