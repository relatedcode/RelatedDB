// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "RelatedDB",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "RelatedDB",
            type: .static,
            targets: ["RelatedDB"]),
    ],
    targets: [
        .target(
            name: "RelatedDB",
            dependencies: [],
            path: "./RelatedDB",
            sources: ["Sources/Core", "Sources/Tools"]
        ),
    ]
)
