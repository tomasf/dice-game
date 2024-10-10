// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dice-game",
    platforms: [.macOS(.v14)], // Needed on macOS
    dependencies: [
        .package(url: "https://github.com/tomasf/SwiftSCAD.git", from: "0.7.1"),
        .package(url: "https://github.com/tomasf/Helical.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "dice-game",
            dependencies: ["SwiftSCAD", "Helical"]
        ),
    ]
)
