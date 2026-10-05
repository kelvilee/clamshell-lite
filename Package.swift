// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ClamshellLite",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "ClamshellCore"),
        .executableTarget(name: "ClamshellLite", dependencies: ["ClamshellCore"]),
        .testTarget(name: "ClamshellCoreTests", dependencies: ["ClamshellCore"]),
    ],
    swiftLanguageModes: [.v5]
)
