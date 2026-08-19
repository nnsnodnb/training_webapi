//
//  TestRefreshValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Testing
@testable import Training
import Vapor

struct TestRefreshValidator {
  @Test("Filled refresh to success")
  func validate() async throws {
    try await makeRequest { request in
      let body = RefreshToken(refresh: "stub_refresh_token")
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try RefreshValidator.validate(content: request)
      }
    }
  }

  @Test("refresh is empty to failure")
  func validateRefreshIsEmpty() async throws {
    try await makeRequest { request in
      let body = RefreshToken(refresh: "")
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try RefreshValidator.validate(content: request)
      }
    }
  }
}
