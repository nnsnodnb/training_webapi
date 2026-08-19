//
//  JWTPayload.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Foundation
import JWTKit

struct JWTPayload: JWTKit::JWTPayload {
  // MARK: - CodingKeys
  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case audience = "aud"
    case expiration = "exp"
    case issuedAt = "iat"
    case userID
  }

  // MARK: - Properties
  var subject: SubjectClaim
  var audience: AudienceClaim
  var expiration: ExpirationClaim
  var issuedAt: IssuedAtClaim
  var userID: UUID

  static func generateAccessToken(issuedAt: Date = .now, userID: UUID) -> Self {
    let expiration = issuedAt.addingTimeInterval(60 * 60) // 1 hour
    return .init(
      subject: .init(value: userID.uuidString),
      audience: .init(value: ["training-api"]),
      expiration: .init(value: expiration),
      issuedAt: .init(value: issuedAt),
      userID: userID,
    )
  }

  static func generateRefreshToken(issuedAt: Date = .now, userID: UUID) -> Self {
    let expiration = issuedAt.addingTimeInterval(60 * 60 * 24 * 7) // 1 week
    return .init(
      subject: .init(value: userID.uuidString),
      audience: .init(value: ["training-api"]),
      expiration: .init(value: expiration),
      issuedAt: .init(value: issuedAt),
      userID: userID,
    )
  }

  func verify(using algorithm: some JWTAlgorithm) async throws {
    if subject.value != userID.uuidString {
      throw JWTError.claimVerificationFailure(failedClaim: subject, reason: "invalid")
    }
    if audience.value != ["training-api"] {
      throw JWTError.claimVerificationFailure(failedClaim: audience, reason: "invalid")
    }
    try expiration.verifyNotExpired()
    if issuedAt.value > Date.now {
      throw JWTError.claimVerificationFailure(failedClaim: issuedAt, reason: "invalid")
    }
  }
}
