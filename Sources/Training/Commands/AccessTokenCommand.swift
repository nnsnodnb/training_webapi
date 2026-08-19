//
//  AccessTokenCommand.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Fluent
import Foundation
import JWT
import Vapor

struct AccessTokenCommand: AsyncCommand {
  struct Signature: CommandSignature {
    // MARK: - Properties
    @Option(name: "user", short: "u", help: "ID of user for generate access token.")
    var user: String?

    // MARK: - Initialize
    init() {
    }
  }

  // MARK: - Error
  enum Error: Swift.Error, CustomStringConvertible {
    case unsupportedEnvironment
    case invalidUserID
    case notFoundUser

    // MARK: - CustomStringConvertible
    var description: String {
      switch self {
      case .unsupportedEnvironment:
        "Unsupported environment"
      case .invalidUserID:
        "Invalid userID"
      case .notFoundUser:
        "Not found user"
      }
    }
  }

  // MARK: - Properties
  let help: String = "Generate access token for specified user"

  func run(using context: CommandContext, signature: Signature) async throws {
    do {
      guard !context.application.environment.isRelease else {
        throw Error.unsupportedEnvironment
      }
      let userID: UUID
      if let user = signature.user {
        if let uuid = UUID(uuidString: user) {
          userID = uuid
        } else {
          throw Error.invalidUserID
        }
      } else {
        let input = context.console.ask("Input userID:")
        guard let uuid = UUID(uuidString: input) else {
          throw Error.invalidUserID
        }
        userID = uuid
      }
      guard try await User.find(userID, on: context.application.db) != nil else {
        throw Error.notFoundUser
      }
      let accessToken = try await context.application.jwt.keys.sign(JWTPayload.generateAccessToken(userID: userID))
      context.console.output(accessToken, style: .success, newLine: true)
    } catch let error as Error {
      context.console.output(error.description, style: .error, newLine: true)
    }
  }
}
