// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UITestsHelpers",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UITestsHelpers",
            targets: ["UITestsHelpers"]),
    ],
    dependencies: [
        .package(path: "../Strings"),
        .package(path: "../../Shared/Localization"),
        .package(url: "https://github.com/lachlanbell/SwiftOTP.git", .upToNextMinor(from: "2.0.3")),
        .package(url: "https://github.com/ProtonMail/TrustKit", .upToNextMinor(from: "1.0.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UITestsHelpers",
            dependencies: [
                "Strings",
                "Localization",
                .product(name: "SwiftOTP", package: "SwiftOTP"),
            ]
        ),

    ]
)
