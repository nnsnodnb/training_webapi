//
//  TestCreateTaskValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Testing
@testable import Training
import Vapor

struct TestCreateTaskValidator {
  @Test("Filled all fields to success")
  func validate() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: "タイトル",
        thumbnail: "/path/to/image.jpg",
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try CreateTaskValidator.validate(content: request)
      }
    }
  }

  @Test("thumbnail is nil to success")
  func validateThumbnailIsNil() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: "タイトル",
        thumbnail: nil,
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try CreateTaskValidator.validate(content: request)
      }
    }
  }

  @Test("title is empty to failure")
  func validateTitleIsEmpty() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: "",
        thumbnail: "/path/to/image.jpg",
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try CreateTaskValidator.validate(content: request)
      }
    }
  }

  @Test("thumbnail is empty to failure")
  func validateThumbnailIsEmpty() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: "タイトル",
        thumbnail: "",
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try CreateTaskValidator.validate(content: request)
      }
    }
  }

  @Test("status is nil to failure")
  func validateStatusIsNil() async throws {
    try await makeRequest { request in
      let body = TaskDTO(
        id: nil,
        title: "タイトル",
        thumbnail: "/path/to/image.jpg",
        status: nil,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try CreateTaskValidator.validate(content: request)
      }
    }
  }
}
