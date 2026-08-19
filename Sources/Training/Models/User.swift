//
//  User.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation
import Vapor

final class User: Model, @unchecked Sendable {
  // MARK: - Properties
  static let schema = "users"

  @ID(key: .id)
  var id: UUID?
  @Field(key: "username")
  var username: String
  @Field(key: "password")
  var password: String
  @Timestamp(key: "date_joined", on: .create, format: .unix)
  var dateJoined: Date?

  // MARK: - Initialize
  init() {
  }

  init(id: UUID? = nil, username: String, password: String) {
    self.id = id
    self.username = username
    self.password = password
  }

  func toDTO() -> UserDTO {
    .init(
      id: id,
      username: username,
      password: password,
      dateJoined: dateJoined,
    )
  }

  func toOutputDTO() -> UserDTO.Output {
    .init(
      id: id,
      username: username,
      dateJoined: dateJoined,
    )
  }
}
