// swift-tools-version: 6.4

import Foundation
import PackageDescription

let package = Package(
    name: "swift-sitemap",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Sitemap", targets: ["Sitemap"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sitemap",
            dependencies: []
        ),
        .testTarget(
            name: "Sitemap Tests",
            dependencies: [.target(name: "Sitemap")]
        ),
    ],
    swiftLanguageModes: [.v5]
)

