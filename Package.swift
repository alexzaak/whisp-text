// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WhispText",
    platforms: [
        .macOS(.v14) // MenuBarExtra and WhisperKit typically require macOS 13 or 14
    ],
    dependencies: [
        // WhisperKit for high-performance transcription on Apple Silicon
        .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0")
    ],
    targets: [
        .executableTarget(
            name: "WhispText",
            dependencies: [
                .product(name: "WhisperKit", package: "WhisperKit")
            ],
            path: "Sources/WhispText"
        )
    ]
)
