import Fluent
import FluentSQLiteDriver
import NIOSSL
import JWT
import Vapor

/// configures your application
func configure(_ app: Application, inMemory: Bool = false) async throws {
  // Middleware
  let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .originBased,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin],
  )
  app.middleware.use(CORSMiddleware(configuration: corsConfiguration), at: .beginning)
  app.middleware.use(MaintenanceMiddleware())
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  // JWT
  await app.jwt.keys.add(hmac: "R5b6V4UAS0HpGYtJXljmn42vahcqY3waKqK1RwaY6CE", digestAlgorithm: .sha256)
  // Database
  if inMemory {
    app.databases.use(.sqlite(.memory), as: .sqlite)
  } else {
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
  }
  migrations(app)
  // Encoding & Decoding
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .millisecondsSince1970
  ContentConfiguration.global.use(encoder: encoder, for: .json)
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .millisecondsSince1970
  ContentConfiguration.global.use(decoder: decoder, for: .json)
  // Routes
  try routes(app)
  // Commands
  app.asyncCommands.use(AccessTokenCommand(), as: "access-token")
  app.asyncCommands.use(MaintenanceCommand(), as: "maintenance")
  // Logging
  // app.logger.logLevel = .debug
}
