//
//  CommentDTO.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation
import Vapor

struct CommentDTO: Content {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case content
    case imageIDs = "image_ids"
    case task
    case user
    case created
  }

  // MARK: - Properties
  var id: UUID?
  var content: String?
  var imageIDs: [String]
  var task: TaskDTO?
  var user: UserDTO?
  var created: Date?

  func toModel() -> Comment {
    let model = Comment()
    model.id = id
    if let content {
      model.content = content
    }
    model.imageIDs = imageIDs
    if let task, let taskID = task.id {
      model.$task.id = taskID
    }
    if let user, let userID = user.id {
      model.$user.id = userID
    }
    model.created = created
    return model
  }
}

// MARK: - Output
extension CommentDTO {
  struct Output: Content {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case id
      case content
      case imageIDs = "image_ids"
      case task
      case user
      case created
    }

    // MARK: - Properties
    let id: UUID?
    let content: String?
    let imageIDs: [String]
    let task: TaskDTO.Output
    let user: UserDTO.Output
    let created: Date?
  }
}
