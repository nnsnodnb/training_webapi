// swift-tools-version:6.3
import PackageDescription

let package = Package(
  name: "Training",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    .package(
      url: "https://github.com/tmthecoder/Argon2Swift.git",
      revision: "53543623fefe68461b7eeea03d7f96677c2fd76d", // v1.0.4
    ),
    // 🔑 JSON Web Token signing and verification with support for JWS and JWK.
    .package(url: "https://github.com/vapor/jwt.git", from: "5.1.2"),
    // 🗄 An ORM for SQL and NoSQL databases.
    .package(url: "https://github.com/vapor/fluent.git", from: "4.13.0"),
    // 🪶 Fluent driver for SQLite.
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.9.0"),
    // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.101.0"),
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4"),
    .package(url: "https://github.com/nnsnodnb/vapor-cursor-pagination.git", from: "0.1.1"),
  ],
  targets: [
    .executableTarget(
      name: "Training",
      dependencies: [
        .argon2Swift,
        .fluent,
        .fluentSQLiteDriver,
        .jwt,
        .nioCore,
        .nioPosix,
        .vapor,
        .vaporCursorPagination,
      ],
      swiftSettings: swiftSettings,
    ),
    .testTarget(
      name: "TrainingTests",
      dependencies: [
        "Training",
        .vaporTesting,
      ],
      resources: [
        .process("Resources"),
      ],
      swiftSettings: swiftSettings,
    )
  ]
)

extension PackageDescription.Target.Dependency {
  static var argon2Swift: Self {
    .product(name: "Argon2Swift", package: "Argon2Swift")
  }
  static var fluent: Self {
    .product(name: "Fluent", package: "fluent")
  }
  static var fluentSQLiteDriver: Self {
    .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
  }
  static var jwt: Self {
    .product(name: "JWT", package: "JWT")
  }
  static var nioCore: Self {
    .product(name: "NIOCore", package: "swift-nio")
  }
  static var nioPosix: Self {
    .product(name: "NIOPosix", package: "swift-nio")
  }
  static var vapor: Self {
    .product(name: "Vapor", package: "vapor")
  }
  static var vaporCursorPagination: Self {
    .product(name: "VaporCursorPagination", package: "vapor-cursor-pagination")
  }
  static var vaporTesting: Self {
    .product(name: "VaporTesting", package: "vapor")
  }
}

var swiftSettings: [SwiftSetting] { [
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
] }
