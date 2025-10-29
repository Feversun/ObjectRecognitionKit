// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ObjectRecognitionKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ObjectRecognitionKit",
            targets: ["ObjectRecognitionKit"]),
    ],
    targets: [
        .target(
            name: "ObjectRecognitionKit"),
        .testTarget(
            name: "ObjectRecognitionKitTests",
            dependencies: ["ObjectRecognitionKit"]),
    ]
)
