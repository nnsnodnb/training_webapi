//
//  TestImageController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Fluent
import JWT
import NIOFoundationEssentialsCompat
import Testing
@testable import Training
import VaporTesting

struct TestImageController {
  private func generateAccessToken(_ keys: JWTKeyCollection, for userID: User.IDValue) async throws -> String {
    try await keys.sign(JWTPayload.generateAccessToken(issuedAt: .now, userID: userID))
  }

  @Test("Upload image")
  func uploadImage() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)

      let accessToken = try await generateAccessToken(app.jwt.keys, for: user.requireID())

      guard let url = Bundle.module.url(forResource: "red", withExtension: "jpg") else {
        Issue.record("Not found red.jpg in TrainingTests target")
        return
      }
      let data = try Data(contentsOf: url)

      var headers = HTTPHeaders()
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .POST,
        "v1/images/",
        headers: headers,
        beforeRequest: { request in
          let file = File(data: ByteBuffer(data: data), filename: "red.jpg")
          let body = ImageDTO(items: [file])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(ImageDTO.Output.self)
          #expect(actual.items.count == 1)
        },
      )
    }
  }

  @Test("Upload image without authorize")
  func uploadImageUnauthorized() async throws {
    try await withMigrationApp { app in
      guard let url = Bundle.module.url(forResource: "red", withExtension: "jpg") else {
        Issue.record("Not found red.jpg in TrainingTests target")
        return
      }
      let data = try Data(contentsOf: url)

      try await app.testing().test(
        .POST,
        "v1/images/",
        beforeRequest: { request in
          let file = File(data: ByteBuffer(data: data), filename: "red.jpg")
          let body = ImageDTO(items: [file])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )
    }
  }
}
