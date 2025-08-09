// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MIDI2ReaderStarter",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MIDI2SpecReader", targets: ["MIDI2SpecReader"]),
    ],
    targets: [
        .executableTarget(
            name: "MIDI2SpecReader",
            path: "Sources/MIDI2SpecReader"
        ),
    ]
)
