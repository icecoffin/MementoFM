// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sync",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Sync",
            targets: ["Sync"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(path: "../CoreUI"),
        .package(path: "../TransientModels"),
        .package(path: "../SharedServicesInterface"),
        .package(path: "../ServiceTestingUtilities")
    ],
    targets: [
        .target(
            name: "Sync",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                "CoreUI",
                "TransientModels",
                "SharedServicesInterface"
            ]
        ),
        .testTarget(
            name: "SyncTests",
            dependencies: [
                "Sync",
                "ServiceTestingUtilities"
            ]
        )
    ]
)
