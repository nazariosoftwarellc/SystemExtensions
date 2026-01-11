// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NZSSystemExtensions",
    platforms: [
        .macOS(.v12),
        .iOS(.v17),
        .macCatalyst(.v13),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "NZSSystemExtensions",
            targets: ["NZSSystemExtensions"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NZSSystemExtensions",
            dependencies: []
        ),
        .testTarget(
            name: "NZSSystemExtensionsTests",
            dependencies: ["NZSSystemExtensions"]
        )
    ]
)
