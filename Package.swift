// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "a11y-balance-mac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "A11yBalance",       // nome dell'eseguibile Swift
            targets: ["A11yBalance"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "A11yBalance",
            path: "Sources/A11yBalance"
        ),
    ]
)
