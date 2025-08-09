// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MIDI2Reader",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Midi2Core", targets: ["Midi2Core"]),
        .executable(name: "MIDI2SpecReader", targets: ["MIDI2SpecReader"]),
    ],
    targets: [
        .target(
            name: "Midi2Core",
            path: "Sources/Midi2Core",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
        .executableTarget(
            name: "MIDI2SpecReader",
            dependencies: ["Midi2Core"],
            path: "Sources/MIDI2SpecReader",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
    ]
)
