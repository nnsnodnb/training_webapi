//
//  UserDTO.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Foundation
import Vapor

struct UserDTO: Content, Authenticatable {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case username
    case password
    case dateJoined = "date_joined"
  }

  // MARK: - Properties
  var id: UUID?
  var username: String?
  var password: String?
  var dateJoined: Date?

  func toModel() -> User {
    let model = User()

    model.id = id
    if let username {
      model.username = username
    }
    if let password {
      model.password = password
    }
    if let dateJoined {
      model.dateJoined = dateJoined
    }
    return model
  }
}

// MARK: - Output
extension UserDTO {
  struct Output: Content {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case id
      case username
      case dateJoined = "date_joined"
    }

    // MARK: - Properties
    let id: UUID?
    let username: String
    let dateJoined: Date?
  }
}
