// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

// import PackageDescription

// let package = Package(
//     name: "cepu-webhook",
//     platforms: [.macOS(.v14)],
//     dependencies: [
//       .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha"),
//       .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", exact: "0.4.0")
//     ],
//     targets: [
//         .executableTarget(
//             name: "cepu-webhook",
//             dependencies: [
//               .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
//               .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events")
//             ]
//         ),
//     ]
// )
//
// linux require lower toolchain version
import PackageDescription

let package = Package(
    name: "cepu-webhook",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", exact: "0.1.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0")
    ],
    targets: [
        .executableTarget(
            name: "cepu-webhook",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            path: "Sources"
        )
    ]
)