// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LibEmojiIM",
  platforms: [
    .macOS(.v15),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "LibEmojiIM",
      targets: ["LibEmojiIM"]
    ),
    .library(
      name: "LibEmojiIMPreferences",
      targets: ["LibEmojiIMPreferences"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/vChewing/IMKSwift.git", from: "26.06.02")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "LibEmojiIMSharedImpl",
      swiftSettings: [.defaultIsolation(MainActor.self)]
    ),
    .target(
      name: "LibEmojiIMPreferences",
      dependencies: [
        "LibEmojiIMSharedImpl",
      ],
      swiftSettings: [.defaultIsolation(MainActor.self)]
    ),
    .target(
      name: "LibEmojiIM",
      dependencies: [
        "LibEmojiIMSharedImpl",
        .product(name: "IMKSwift", package: "IMKSwift"),
      ],
      resources: [.process("Resources")],
      swiftSettings: [.defaultIsolation(MainActor.self)]
    ),
    .testTarget(
      name: "LibEmojiIMTests",
      dependencies: ["LibEmojiIM"],
      swiftSettings: [.defaultIsolation(MainActor.self)]
    ),
  ],
  swiftLanguageModes: [.v6]
)
