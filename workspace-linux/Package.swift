// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Midi2Linux",
    products: [
        .library(name: "Midi2Core", targets: ["Midi2Core"]),
        .executable(name: "midi2-export", targets: ["midi2-export"])
    ],
    targets: [
        .target(name: "Midi2Core"),
        .executableTarget(name: "midi2-export", dependencies: ["Midi2Core"]),
        .testTarget(name: "Midi2CoreTests", dependencies: ["Midi2Core"])
    ]
)
