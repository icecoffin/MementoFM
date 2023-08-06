// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Persistence",
            targets: ["Persistence"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers.git", exact: "0.9.1"),
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.34.1"),
        .package(path: "../PersistenceInterface"),
        .package(path: "../TransientModels"),
        .package(path: "../InfrastructureTestingUtilities")
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "RealmSwift", package: "realm-swift"),
                "PersistenceInterface",
                "TransientModels"
            ]),
        .testTarget(
            name: "PersistenceTests",
            dependencies: [
                "Persistence",
                "InfrastructureTestingUtilities"
            ]
        )
    ]
)
