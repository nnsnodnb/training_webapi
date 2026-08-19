//
//  TestUploadImageValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import NIOFoundationEssentialsCompat
import Testing
@testable import Training
import VaporTesting

struct TestUploadImageValidator {
  @Test("Filled images field to success")
  func validate() async throws {
    guard let url = Bundle.module.url(forResource: "red", withExtension: "jpg") else {
      Issue.record("Not found red.jpg in TrainingTests target")
      return
    }
    let data = try Data(contentsOf: url)

    try await makeRequest { request in
      let file = File(data: ByteBuffer(data: data), filename: "red.jpg")
      let body = ImageDTO(items: [file])
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try UploadImageValidator.validate(content: request)
      }
    }
  }

  @Test("images field is empty to failure")
  func validateImagesIsEmpty() async throws {
    try await makeRequest { request in
      let body = ImageDTO(items: [])
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UploadImageValidator.validate(content: request)
      }
    }
  }

  @Test("images field is large than 4 count to failure")
  func validateImagesIsLargeThan4Count() async throws {
    guard let url = Bundle.module.url(forResource: "red", withExtension: "jpg") else {
      Issue.record("Not found red.jpg in TrainingTests target")
      return
    }
    let data = try Data(contentsOf: url)

    try await makeRequest { request in
      let files = (0...4).map { File(data: ByteBuffer(data: data), filename: "red_\($0).jpg") }
      let body = ImageDTO(items: files)
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UploadImageValidator.validate(content: request)
      }
    }
  }

  @Test("images field is not image to failure")
  func validateImagesIsNotImage() async throws {
    guard let url = Bundle.module.url(forResource: "empty", withExtension: "txt") else {
      Issue.record("Not found empty.txt in TrainingTests target")
      return
    }
    let data = try Data(contentsOf: url)

    try await makeRequest { request in
      let files = (0...4).map { File(data: ByteBuffer(data: data), filename: "red_\($0).jpg") }
      let body = ImageDTO(items: files)
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try UploadImageValidator.validate(content: request)
      }
    }
  }
}
