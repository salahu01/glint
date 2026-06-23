// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FloatingClock",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "FloatingClock",
            path: "Sources/FloatingClock"
        )
    ]
)
