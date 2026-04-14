// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Metal-Renderer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Metal-Renderer", targets: ["Metal-Renderer"])
    ],
    targets: [
        .executableTarget(
            name: "Metal-Renderer",
            path: "Sources/Metal-Renderer",
            resources: [
                .process("Shaders"),
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Metal-RendererTests",
            dependencies: ["Metal-Renderer"]
        ),
    ]
)
