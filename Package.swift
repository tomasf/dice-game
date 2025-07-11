// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "dice-game",
    platforms: [.macOS(.v14)], // Needed on macOS
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/tomasf/Helical.git", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "dice-game",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
