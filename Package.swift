// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "RelatedDB",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RelatedDB",
            targets: ["RelatedDB"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "RelatedDB",
            path: "./RelatedDB.xcframework"
        )
    ]
)
