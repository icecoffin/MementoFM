// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Settings",
            targets: ["Settings"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(path: "../CoreUI"),
        .package(path: "../SharedServicesInterface"),
        .package(path: "../Sync"),
        .package(path: "../IgnoredTagsInterface"),
        .package(path: "../EnterUsername")
    ],
    targets: [
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                "CoreUI",
                "SharedServicesInterface",
                "Sync",
                "IgnoredTagsInterface",
                "EnterUsername"
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"]
        )
    ]
)
