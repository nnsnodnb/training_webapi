//
//  Task.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Task: Model, @unchecked Sendable {
  // MARK: - Status
  enum Status: String, CaseIterable, Codable {
    case backlog
    case inProgress = "in_progress"
    case inReview = "in_review"
    case finished
  }

  // MARK: - Properties
  static let schema = "tasks"

  @ID(key: .id)
  var id: UUID?
  @Field(key: "title")
  var title: String
  @OptionalField(key: "thumbnail")
  var thumbnail: String?
  @Enum(key: "status")
  var status: Status
  @Parent(key: "user_id")
  var user: User
  @Timestamp(key: "created", on: .create, format: .unix)
  var created: Date?
  @Timestamp(key: "updated", on: .update, format: .unix)
  var updated: Date?

  // MARK: - Initialize
  init() {
  }

  init(id: UUID? = nil, title: String, thumbnail: String?, status: Status, userID: User.IDValue, created: Date?, updated: Date?) {
    self.id = id
    self.title = title
    self.thumbnail = thumbnail
    self.status = status
    self.$user.id = userID
    self.created = created
    self.updated = updated
  }

  func toDTO() -> TaskDTO {
    .init(
      id: id,
      title: $title.value,
      thumbnail: thumbnail,
      status: status,
      user: user.toDTO(),
      createdAt: created,
      updatedAt: updated,
    )
  }

  func toOutputDTO() -> TaskDTO.Output {
    .init(
      id: id,
      title: $title.value,
      thumbnail: thumbnail,
      status: status,
      user: user.toOutputDTO(),
      createdAt: created,
      updatedAt: updated,
    )
  }
}
