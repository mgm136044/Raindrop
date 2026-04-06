// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "RainDrop",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "RainDrop", targets: ["RainDrop"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "RainDrop",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ],
            path: "Sources/RainDrop"
        ),
    ]
)
