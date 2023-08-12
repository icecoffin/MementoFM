// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfrastructureTestingUtilities",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "InfrastructureTestingUtilities",
            targets: ["InfrastructureTestingUtilities"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", exact: "11.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.11.1"),
        .package(path: "../TransientModels")
    ],
    targets: [
        .target(
            name: "InfrastructureTestingUtilities",
            dependencies: [
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "TransientModels"
            ]
        )
      ]
)
