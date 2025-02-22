// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Localization",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
    ],
    dependencies: [
        .package(path: "../../Foundations/Domain"),
        .package(path: "../../Foundations/Strings"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.4.1"),
        .package(path: "../../../external/protoncore"),
    ],
    targets: [
        .target(
            name: "Localization",
            dependencies: [
                "Domain",
                "Strings",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "ProtonCoreUtilities", package: "protoncore"),
            ]
        ),
        .testTarget(
            name: "LocalizationTests",
            dependencies: ["Localization"]
        )
    ]
)
