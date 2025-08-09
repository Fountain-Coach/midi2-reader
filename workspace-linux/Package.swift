// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Midi2Linux",
    products: [
        .library(name: "Midi2Core", targets: ["Midi2Core"]),
        .executable(name: "midi2-export", targets: ["midi2-export"])
    ],
    dependencies: [
        .package(url: "https://github.com/PureSwift/Cairo.git", branch: "master")
    ],
    targets: [
        .systemLibrary(
            name: "CPoppler",
            pkgConfig: "poppler-glib",
            providers: [
                .apt(["libpoppler-glib-dev"])
            ]
        ),
        .target(
            name: "Midi2Core",
            dependencies: [
                "CPoppler",
                .product(name: "Cairo", package: "Cairo")
            ]
        ),
        .executableTarget(
            name: "midi2-export",
            dependencies: ["Midi2Core"]
        ),
        .testTarget(
            name: "Midi2CoreTests",
            dependencies: ["Midi2Core"]
        ),
        .testTarget(
            name: "PDFTests",
            dependencies: ["Midi2Core"]
        ),
        .testTarget(
            name: "ExporterTests",
            dependencies: ["Midi2Core"]
        ),
        .testTarget(
            name: "CLITests",
            dependencies: ["midi2-export"]
        )
    ]
)
