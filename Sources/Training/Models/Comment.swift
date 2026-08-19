//
//  Comment.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation

final class Comment: Model, @unchecked Sendable {
  // MARK: - Properties
  static let schema = "comments"

  @ID(key: .id)
  var id: UUID?
  @Field(key: "content")
  var content: String
  @Field(key: "image_ids")
  var imageIDs: [String]
  @Parent(key: "task_id")
  var task: Task
  @Parent(key: "user_id")
  var user: User
  @Timestamp(key: "created", on: .create)
  var created: Date?

  // MARK: - Initialize
  init() {
  }

  init(id: UUID? = nil, content: String, imageIDs: [String], taskID: Task.IDValue, userID: User.IDValue, created: Date?) {
    self.id = id
    self.content = content
    self.imageIDs = imageIDs
    self.$task.id = taskID
    self.$user.id = userID
    self.created = created
  }

  func toDTO() -> CommentDTO {
    .init(
      id: id,
      content: $content.value,
      imageIDs: imageIDs,
      task: task.toDTO(),
      user: user.toDTO(),
      created: created,
    )
  }

  func toOutputDTO() -> CommentDTO.Output {
    .init(
      id: id,
      content: $content.value,
      imageIDs: imageIDs,
      task: task.toOutputDTO(),
      user: user.toOutputDTO(),
      created: created,
    )
  }
}
