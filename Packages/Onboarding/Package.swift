// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers.git", exact: "0.9.1"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0"),
        .package(url: "https://github.com/michaeltyson/TPKeyboardAvoiding.git", exact: "1.3.5"),
        .package(name: "CoreUI", path: "./CoreUI"),
        .package(name: "SharedServicesInterface", path: "./SharedServicesInterface"),
        .package(name: "Sync", path: "./Sync")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "TPKeyboardAvoiding", package: "TPKeyboardAvoiding"),
                "CoreUI",
                "SharedServicesInterface",
                "Sync"
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: ["Onboarding"]
        )
    ]
)
