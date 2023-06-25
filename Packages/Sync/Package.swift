// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sync",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Sync",
            targets: ["Sync"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(name: "CoreUI", path: "./CoreUI"),
        .package(name: "TransientModels", path: "./TransientModels")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Sync",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                "CoreUI",
                "TransientModels"
            ]
        ),
        .testTarget(
            name: "SyncTests",
            dependencies: ["Sync"]
        )
    ]
)
