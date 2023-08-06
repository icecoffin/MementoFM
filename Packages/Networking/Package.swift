// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.6.4"),
        .package(path: "../Core"),
        .package(path: "../NetworkingInterface")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                "Core",
                "NetworkingInterface"
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        )
    ]
)
