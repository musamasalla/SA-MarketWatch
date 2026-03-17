// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SA-MarketWatch",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SA-MarketWatch",
            targets: ["SA-MarketWatch"]
        )
    ],
    targets: [
        .target(
            name: "SA-MarketWatch",
            path: "SA-MarketWatch"
        )
    ]
)
