// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftForgeUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "SwiftForgeUI", targets: ["SwiftForgeUI"])
    ],
    targets: [
        .target(
            name: "SwiftForgeUI",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SwiftForgeUITests",
            dependencies: ["SwiftForgeUI"]
        ),
    ]
)
