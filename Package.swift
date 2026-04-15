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
    dependencies: [
        .package(
            url: "https://github.com/warrenm/GLTFKit2",
            from: "0.5.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "Metal-Renderer",
            dependencies: [
                .product(name: "GLTFKit2", package: "GLTFKit2")
            ],
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
