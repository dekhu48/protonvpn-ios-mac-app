// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NEHelper",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
        .tvOS(.v17),
    ],
    products: [
        .library(name: "NEHelper", targets: ["NEHelper"]),
        .library(name: "VPNAppCore", targets: ["VPNAppCore"]),
        .library(name: "VPNShared", targets: ["VPNShared"]),
        .library(name: "VPNCrypto", targets: ["VPNCrypto"]),
        .library(name: "VPNSharedTesting", targets: ["VPNSharedTesting"]),
    ],
    dependencies: [
        .package(path: "../../external/protoncore"),

        .package(path: "../Foundations/Domain"),
        .package(path: "../Foundations/Ergonomics"),
        .package(path: "../NetShield"),
        .package(path: "../Foundations/LocalFeatureFlags"),
        .package(path: "../Foundations/PMLogger"),
        .package(path: "../Foundations/Strings"),
        .package(path: "../Foundations/Timer"),
        .package(path: "../Shared/Localization"),

        .package(path: "../Shared/ExtensionIPC"),

        .package(url: "https://github.com/apple/swift-log.git", exact: "1.4.4"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", exact: "4.2.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "1.4.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.15.1")),
        .package(url: "https://github.com/getsentry/sentry-cocoa", exact: "8.36.0"),
    ],
    targets: [
        .target(
            name: "VPNShared",
            dependencies: [
                "Domain",
                "ExtensionIPC",
                "VPNCrypto",
                .product(name: "Ergonomics", package: "Ergonomics"),
                .product(name: "Timer", package: "Timer"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "PMLogger", package: "PMLogger"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "LocalFeatureFlags", package: "LocalFeatureFlags"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "NEHelper",
            dependencies: [
                "Ergonomics",
                "ExtensionIPC",
                "VPNShared",
                .product(name: "Timer", package: "Timer"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "LocalFeatureFlags", package: "LocalFeatureFlags"),
                .core(module: "Utilities")
            ]
        ),
        .target(
            name: "VPNAppCore",
            dependencies: [
                "Domain",
                "NetShield",
                "VPNShared",
                "VPNCrypto",
                "Strings",
                "Localization",
                .product(name: "ProtonCoreUtilities", package: "protoncore"),
                .product(name: "ProtonCoreFeatureFlags", package: "protoncore"),
                .product(name: "ProtonCoreNetworking", package: "protoncore"), // AuthCredential
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "VPNCrypto",
            dependencies: [
                "Ergonomics",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "VPNSharedTesting",
            dependencies: ["VPNShared",
                           .core(module: "FeatureFlags"),
                .product(name: "TimerMock", package: "Timer")]
        ),
        .testTarget(name: "VPNSharedTests", dependencies: ["VPNShared"]),
        .testTarget(name: "NEHelperTests", dependencies: ["NEHelper", "VPNSharedTesting"]),
        .testTarget(name: "VPNCryptoTests", dependencies: ["VPNCrypto"])
    ]
)

extension PackageDescription.Target.Dependency {
    static func core(module: String) -> Self {
        .product(name: "ProtonCore\(module)", package: "protoncore")
    }
}
