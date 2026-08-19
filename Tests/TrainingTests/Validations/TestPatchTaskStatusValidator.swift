//
//  TestPatchTaskStatusValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Testing
@testable import Training
import Vapor

struct TestPatchTaskStatusValidator {
  @Test("Filled all fields to success")
  func validate() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: nil,
        thumbnail: nil,
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil
      )
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try PatchTaskStatusValidator.validate(content: request)
      }
    }
  }

  @Test("status is nil to failure")
  func validateStatusIsNil() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: nil,
        thumbnail: nil,
        status: nil,
        user: nil,
        createdAt: nil,
        updatedAt: nil
      )
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try PatchTaskStatusValidator.validate(content: request)
      }
    }
  }
}
