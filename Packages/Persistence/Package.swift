// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Persistence",
            targets: ["Persistence"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.34.1"),
        .package(name: "TransientModels", path: "./TransientModels")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
                "TransientModels"
            ]),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"]
        )
    ]
)
