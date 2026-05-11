// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NavicatMac",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "NavicatMac",
            path: "NavicatMac"
        ),
        .testTarget(
            name: "NavicatMacTests",
            dependencies: ["NavicatMac"],
            path: "NavicatMacTests"
        )
    ]
)