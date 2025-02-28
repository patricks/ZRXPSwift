// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ZRXPSwift",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ZRXPSwift",
            targets: ["ZRXPSwift"]
        )
    ],
    targets: [
        .target(name: "ZRXPSwift")
    ],
    swiftLanguageModes: [.v6]
)
