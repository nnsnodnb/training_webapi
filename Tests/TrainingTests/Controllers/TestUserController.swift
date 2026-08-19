//
//  TestUserController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/13.
//

import Argon2Swift
import Fluent
import JWT
import Testing
@testable import Training
import VaporTesting

struct TestUserController {
  @Test("Test sign-in Route at first")
  func testSignInAtFirst() async throws {
    let dto = UserDTO(username: "nnsnodnb", password: "very_secret_password")

    try await withMigrationApp { app in
      try await app.testing().test(
        .POST,
        "v1/users/sign-in/",
        beforeRequest: { request in
          try request.content.encode(dto)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let tokens = try response.content.decode(Tokens.self)
          #expect(!tokens.refreshToken.isEmpty)
          #expect(!tokens.accessToken.isEmpty)
        },
      )
    }
  }

  @Test("Test sign-in Route already user valid credential")
  func testSignInAlreadyUserValidCredential() async throws {
    let result = try Argon2Swift.hashPasswordString(password: "very_secret_password", salt: .newSalt(length: 32))
    var dto = UserDTO(username: "nnsnodnb", password: result.encodedString())

    try await withMigrationApp { app in
      try await dto.toModel().save(on: app.db)

      dto.password = "very_secret_password"

      try await app.testing().test(
        .POST,
        "v1/users/sign-in/",
        beforeRequest: { request in
          try request.content.encode(dto)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let tokens = try response.content.decode(Tokens.self)
          #expect(!tokens.refreshToken.isEmpty)
          #expect(!tokens.accessToken.isEmpty)
        },
      )
    }
  }

  @Test("Test sign-in Route already user wrong credential")
  func testSignInAlreadyUserWrongCredential() async throws {
    let result = try Argon2Swift.hashPasswordString(password: "very_secret_password", salt: .newSalt(length: 32))
    var dto = UserDTO(username: "nnsnodnb", password: result.encodedString())

    try await withMigrationApp { app in
      try await dto.toModel().save(on: app.db)

      dto.password = "very_s3cret_password"

      try await app.testing().test(
        .POST,
        "v1/users/sign-in/",
        beforeRequest: { request in
          try request.content.encode(dto)
        },
        afterResponse: { response in
          #expect(response.status == .badRequest)
        },
      )
    }
  }

  @Test("Refresh access token")
  func testRefreshAccessToken() async throws {
    let result = try Argon2Swift.hashPasswordString(password: "very_secret_password", salt: .newSalt(length: 32))
    let dto = UserDTO(username: "nnsnodnb", password: result.encodedString())

    try await withMigrationApp { app in
      let user = dto.toModel()
      try await user.save(on: app.db)

      try await app.testing().test(
        .POST,
        "v1/users/refresh/",
        beforeRequest: { request in
          let payload = JWTPayload.generateRefreshToken(userID: try user.requireID())
          let refreshToken = try await app.jwt.keys.sign(payload)
          let body = RefreshToken(refresh: refreshToken)
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let tokens = try response.content.decode(Tokens.self)
          #expect(!tokens.refreshToken.isEmpty)
          #expect(!tokens.accessToken.isEmpty)
        },
      )
    }
  }

  @Test("Delete user")
  func testDeleteUserMe() async throws {
    let result = try Argon2Swift.hashPasswordString(password: "very_secret_password", salt: .newSalt(length: 32))
    let dto = UserDTO(username: "nnsnodnb", password: result.encodedString())

    try await withMigrationApp { app in
      let user = dto.toModel()
      try await user.save(on: app.db)
      let userID = try user.requireID()

      try await app.testing().test(
        .DELETE,
        "v1/users/me/",
        beforeRequest: { request in
          let payload = JWTPayload.generateAccessToken(userID: userID)
          let accessToken = try await app.jwt.keys.sign(payload)
          request.headers.bearerAuthorization = .init(token: accessToken)
        },
        afterResponse: { response in
          #expect(response.status == .noContent)
          let actual = try await User.find(userID, on: app.db)
          #expect(actual == nil)
        },
      )
    }
  }
}
