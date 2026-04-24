// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RoyalTracker",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "RoyalTracker", targets: ["RoyalTracker"])
    ],
    targets: [
        .executableTarget(
            name: "RoyalTracker",
            path: "Sources/RoyalTracker"
        )
    ]
)
