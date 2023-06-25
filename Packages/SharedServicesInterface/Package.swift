// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedServicesInterface",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SharedServicesInterface",
            targets: ["SharedServicesInterface"]
        )
    ],
    dependencies: [
        .package(name: "TransientModels", path: "./TransientModels"),
        .package(name: "PersistenceInterface", path: "./PersistenceInterface")
    ],
    targets: [
        .target(
            name: "SharedServicesInterface",
            dependencies: [
                "TransientModels",
                "PersistenceInterface"
            ]
        )
    ]
)
