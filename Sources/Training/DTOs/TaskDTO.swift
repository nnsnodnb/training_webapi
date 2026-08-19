//
//  UserDTO.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation
import Vapor

struct TaskDTO: Content {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case thumbnail
    case status
    case user
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }

  // MARK: - Properties
  var id: UUID?
  var title: String?
  var thumbnail: String?
  var status: Task.Status?
  var user: UserDTO?
  var createdAt: Date?
  var updatedAt: Date?

  // MARK: - Initialize
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
    self.title = try container.decodeIfPresent(String.self, forKey: .title)
    self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
    self.status = try container.decodeIfPresent(Task.Status.self, forKey: .status) ?? .backlog
    self.user = try container.decodeIfPresent(UserDTO.self, forKey: .user)
    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
  }

  init(
    id: UUID?,
    title: String?,
    thumbnail: String?,
    status: Task.Status? = .backlog,
    user: UserDTO?,
    createdAt: Date?,
    updatedAt: Date?,
  ) {
    self.id = id
    self.title = title
    self.thumbnail = thumbnail
    self.status = status
    self.user = user
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  func toModel() -> Task {
    let model = Task()

    model.id = id
    if let title {
      model.title = title
    }
    if let thumbnail {
      model.thumbnail = thumbnail
    }
    if let status {
      model.status = status
    }
    if let user, let userID = user.id {
      model.$user.id = userID
    }
    if let createdAt {
      model.created = createdAt
    }
    if let updatedAt {
      model.updated = updatedAt
    }
    return model
  }
}

// MARK: - Output
extension TaskDTO {
  struct Output: Content {
    let id: UUID?
    let title: String?
    let thumbnail: String?
    let status: Task.Status?
    let user: UserDTO.Output
    let createdAt: Date?
    let updatedAt: Date?
  }
}
