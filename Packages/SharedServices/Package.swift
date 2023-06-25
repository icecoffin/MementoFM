// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedServices",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SharedServices",
            targets: ["SharedServices"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers.git", exact: "0.9.1"),
        .package(name: "SharedServicesInterface", path: "./SharedServicesInterface"),
        .package(name: "Persistence", path: "./Persistence")
    ],
    targets: [
        .target(
            name: "SharedServices",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                "SharedServicesInterface",
                "Persistence"
            ]
        ),
        .testTarget(
            name: "SharedServicesTests",
            dependencies: ["SharedServices"]
        )
    ]
)
