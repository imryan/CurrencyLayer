// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CurrencyLayer",
    products: [
            .executable(name: "currency-layer", targets: ["CurrencyLayer"])
        ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "CurrencyLayer",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "CurrencyLayerTests",
            dependencies: ["CurrencyLayer"]),
    ]
)
