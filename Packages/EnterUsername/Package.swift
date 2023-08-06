// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnterUsername",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "EnterUsername",
            targets: ["EnterUsername"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(path: "../CoreUI"),
        .package(path: "../SharedServicesInterface"),
        .package(path: "../ServiceTestingUtilities")
    ],
    targets: [
        .target(
            name: "EnterUsername",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                "CoreUI",
                "SharedServicesInterface"
            ]
        ),
        .testTarget(
            name: "EnterUsernameTests",
            dependencies: [
                "EnterUsername",
                "ServiceTestingUtilities"
            ]
        )
    ]
)
