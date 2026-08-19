//
//  TestUpsertCommentValidation.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Testing
@testable import Training
import Vapor

struct TestUpsertCommentValidation {
  @Test(
    "Filled all fields to success",
    arguments: [
      ["/images/path/to/image.jpg"],
      (0..<4).map { "/images/path/to/image\($0).jpg" },
      [],
    ],
  )
  func validate(imageIDs: [String]) async throws {
    try await makeRequest { request in
      let content = (0..<500).map { _ in "a" }.joined()
      let body = CommentDTO(content: content, imageIDs: imageIDs)
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try UpsertCommentValidator.validate(content: request)
      }
    }
  }

  @Test("content is nil to failure")
  func validateContentIsNil() async throws {
    try await makeRequest { request in
      let body = CommentDTO(content: nil, imageIDs: ["/images/path/to/image.jpg"])
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UpsertCommentValidator.validate(content: request)
      }
    }
  }

  @Test("content is empty to failure")
  func validateContentIsEmpty() async throws {
    try await makeRequest { request in
      let body = CommentDTO(content: "", imageIDs: ["/images/path/to/image.jpg"])
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UpsertCommentValidator.validate(content: request)
      }
    }
  }

  @Test("content is over max length to failure")
  func validateContentIsOverMaxLengh() async throws {
    try await makeRequest { request in
      let content = (0...500).map { _ in "a" }.joined()
      let body = CommentDTO(content: content, imageIDs: ["/images/path/to/image.jpg"])
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UpsertCommentValidator.validate(content: request)
      }
    }
  }

  @Test("imageIDs is over max length to failure")
  func validateImageIDsIsOverMaxLengh() async throws {
    try await makeRequest { request in
      let imageIDs = (0...4).map { "/images/path/to/image\($0).jpg" }
      let body = CommentDTO(content: "コメント", imageIDs: imageIDs)
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UpsertCommentValidator.validate(content: request)
      }
    }
  }
}
