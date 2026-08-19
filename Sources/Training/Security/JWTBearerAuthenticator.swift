//
//  JWTBearerAuthenticator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation
import JWT
import Vapor

struct JWTBearerAuthenticator: AsyncBearerAuthenticator {
  func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
    let payload: JWTPayload
    do {
      payload = try await request.jwt.verify(as: JWTPayload.self)
    } catch {
      throw Abort(.unauthorized)
    }
    guard let user = try await User.find(payload.userID, on: request.db) else {
      throw Abort(.unauthorized)
    }
    request.auth.login(user.toDTO())
  }
}
