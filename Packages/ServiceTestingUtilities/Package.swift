// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceTestingUtilities",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ServiceTestingUtilities",
            targets: ["ServiceTestingUtilities"]
        )
    ],
    dependencies: [
        .package(path: "../SharedServicesInterface"),
        .package(path: "../PersistenceInterface"),
        .package(path: "../InfrastructureTestingUtilities"),
        .package(path: "../NetworkingInterface")
    ],
    targets: [
        .target(
            name: "ServiceTestingUtilities",
            dependencies: [
                "SharedServicesInterface",
                "PersistenceInterface",
                "InfrastructureTestingUtilities",
                "NetworkingInterface"
            ]
        )
    ]
)
