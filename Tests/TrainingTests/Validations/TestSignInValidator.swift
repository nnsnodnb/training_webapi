//
//  TestSignInValidator.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Foundation
import Testing
@testable import Training
import Vapor

struct TestSignInValidator {
  @Test("Filled all fields to success")
  func validate() async throws {
    try await makeRequest { request in
      let body = UserDTO(username: "nnsnodnb", password: "very_secret_password")
      try request.content.encode(body)

      #expect(throws: Never.self) {
        try SignInValidator.validate(content: request)
      }
    }
  }

  @Test("username is nil to failure")
  func validateUsernameIsNil() async throws {
    try await makeRequest { request in
      let body = UserDTO(password: "very_secret_password")
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try SignInValidator.validate(content: request)
      }
    }
  }

  @Test("username is empty to failure")
  func validateUsernameIsEmpty() async throws {
    try await makeRequest { request in
      let body = UserDTO(username: "", password: "very_secret_password")
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try SignInValidator.validate(content: request)
      }
    }
  }

  @Test("password is nil to failure")
  func validatePasswordIsNil() async throws {
    try await makeRequest { request in
      let body = UserDTO(username: "nnsnodnb")
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try SignInValidator.validate(content: request)
      }
    }
  }

  @Test("password length is less than 8 to failure")
  func validatePasswordIsLessThan8Length() async throws {
    try await makeRequest { request in
      let body = UserDTO(password: "passwd")
      try request.content.encode(body)

      #expect(throws: ValidationsError.self) {
        try SignInValidator.validate(content: request)
      }
    }
  }
}
