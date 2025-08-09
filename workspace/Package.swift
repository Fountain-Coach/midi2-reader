// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MIDI2ReaderStarter",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Midi2Core", targets: ["Midi2Core"]),
        .executable(name: "MIDI2SpecReader", targets: ["MIDI2SpecReader"]),
        .executable(name: "midi2-export", targets: ["midi2-export"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "Midi2Core",
            path: "Sources/Midi2Core"
        ),
        .executableTarget(
            name: "MIDI2SpecReader",
            dependencies: ["Midi2Core"],
            path: "Sources/MIDI2SpecReader"
        ),
        .executableTarget(
            name: "midi2-export",
            dependencies: [
                "Midi2Core",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/midi2-export",
            resources: [
                .copy("../../Inputs")
            ]
        ),
        .testTarget(
            name: "Midi2CoreTests",
            dependencies: ["Midi2Core"],
            path: "Tests/Midi2CoreTests"
        )
    ]
)
