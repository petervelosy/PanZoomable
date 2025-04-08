// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PanZoomable",
    platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v13), .watchOS(.v10)],
    products: [
        .library(
            name: "PanZoomable",
            targets: ["PanZoomable"]),
    ],
    targets: [
        .target(
            name: "PanZoomable"),
        .testTarget(
            name: "PanZoomableTests",
            dependencies: ["PanZoomable"]
        ),
    ]
)
