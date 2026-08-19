//
//  UserController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Argon2Swift
import Fluent
import JWT
import Vapor

struct UserController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let users = routes.grouped("v1", "users")

    users.post("sign-in", use: signIn)
    users.post("refresh", use: refresh)

    let usersProtected = users.grouped(JWTBearerAuthenticator())
      .grouped(UserDTO.guardMiddleware())

    usersProtected.delete("me", use: deleteMe)
  }

  @Sendable
  func signIn(request: Request) async throws -> Response {
    try SignInValidator.validate(content: request)
    let data = try request.content.decode(UserDTO.self)
    guard let username = data.username, let password = data.password else {
      throw Abort(.badGateway)
    }

    let authenticateUser: UserDTO
    if let user = try await User.query(on: request.db)
      .filter(\.$username == username)
      .first() {
      do {
        guard try Argon2Swift.verifyHashString(password: password, hash: user.password) else {
          let body = ErrorResponse(error: "ユーザー名またはパスワードが間違っています。")
          let response = Response(status: .badRequest)
          try response.content.encode(body, as: .json)
          return response
        }
      } catch {
        // Wrong password
        let body = ErrorResponse(error: "ユーザー名またはパスワードが間違っています。")
        let response = Response(status: .badRequest)
        try response.content.encode(body, as: .json)
        return response
      }
      authenticateUser = user.toDTO()
    } else {
      let result = try Argon2Swift.hashPasswordString(password: password, salt: .newSalt(length: 32))
      let passwordHash = result.encodedString()
      let user = User(username: username, password: passwordHash)
      try await user.save(on: request.db)
      authenticateUser = user.toDTO()
    }
    request.auth.login(authenticateUser)

    let tokens = try await generateTokens(request: request, userID: authenticateUser.id!)
    let res = Response(status: .ok)
    try res.content.encode(tokens, as: .json)
    return res
  }

  @Sendable
  func refresh(request: Request) async throws -> Response {
    try RefreshValidator.validate(content: request)
    let data = try request.content.decode(RefreshToken.self, as: .json)

    let payload: JWTPayload
    do {
      payload = try await request.jwt.verify(data.refresh, as: JWTPayload.self)
    } catch {
      let body = ErrorResponse(error: "refreshが無効または期限切れです。")
      let response = Response(status: .badRequest)
      try response.content.encode(body, as: .json)
      return response
    }
    guard let user = try await User.find(payload.userID, on: request.db) else {
      return Response(status: .notFound)
    }
    request.auth.login(user.toDTO())
    let tokens = try await generateTokens(request: request, userID: payload.userID)
    let response = Response(status: .ok)
    try response.content.encode(tokens, as: .json)
    return response
  }

  @Sendable
  func deleteMe(request: Request) async throws -> Response {
    let user = try request.auth.require(UserDTO.self).toModel()
    let userID = try user.requireID()
    try await user.delete(on: request.db)
    // ユーザーのアップロードフォルダを削除
    Swift::Task.detached(priority: .background) {
      let userDirectory = "\(request.application.directory.publicDirectory)images/\(userID.uuidString)/"
      guard FileManager.default.fileExists(atPath: userDirectory) else { return }
      try FileManager.default.removeItem(atPath: userDirectory)
    }
    return Response(status: .noContent)
  }

  private func generateTokens(request: Request, userID: UUID) async throws -> Tokens {
    let issuedAt = Date.now
    async let refreshToken = try request.jwt.sign(
      JWTPayload.generateRefreshToken(issuedAt: issuedAt, userID: userID)
    )
    async let accessToken = try request.jwt.sign(
      JWTPayload.generateAccessToken(issuedAt: issuedAt, userID: userID)
    )
    let tokens = Tokens(refreshToken: try await refreshToken, accessToken: try await accessToken)

    return tokens
  }
}
