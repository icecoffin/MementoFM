// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IgnoredTags",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "IgnoredTags",
            targets: ["IgnoredTags"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(url: "https://github.com/michaeltyson/TPKeyboardAvoiding.git", exact: "1.3.5"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers.git", exact: "0.9.1"),
        .package(path: "../IgnoredTagsInterface"),
        .package(path: "../CoreUI"),
        .package(path: "../TransientModels"),
        .package(path: "../SharedServicesInterface"),
        .package(path: "../ServiceTestingUtilities")
    ],
    targets: [
        .target(
            name: "IgnoredTags",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "TPKeyboardAvoiding", package: "TPKeyboardAvoiding"),
                "IgnoredTagsInterface",
                "CoreUI",
                "TransientModels",
                "SharedServicesInterface"
            ]
        ),
        .testTarget(
            name: "IgnoredTagsTests",
            dependencies: [
                "IgnoredTags",
                "ServiceTestingUtilities"
            ]
        )
    ]
)
