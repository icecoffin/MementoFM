// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers.git", exact: "0.9.1"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(path: "../CoreUI"),
        .package(path: "../SharedServicesInterface"),
        .package(path: "../Sync"),
        .package(path: "../IgnoredTagsInterface"),
        .package(path: "../EnterUsername")
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "SnapKit", package: "SnapKit"),
                "CoreUI",
                "SharedServicesInterface",
                "Sync",
                "IgnoredTagsInterface",
                "EnterUsername"
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: ["Onboarding"]
        )
    ]
)
