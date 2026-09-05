//
//  StreamComment.swift
//  Training
//
//  Created by Yuya Oka on 2026/09/05.
//

import Foundation

struct StreamComment: Encodable {
  // MARK: - Mode
  enum Mode: Encodable {
    case created(CommentDTO.Output)
    case modified(CommentDTO.Output)
    case deleted(Comment.IDValue)

    // MARK: - presentedMode
    var presentedMode: String {
      switch self {
      case .created:
        "created"
      case .modified:
        "modified"
      case .deleted:
        "deleted"
      }
    }
  }

  // MARK: - Properties
  let mode: Mode

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case mode
    case comment
    case commentID = "comment_id"
  }

  // MARK: - Encodable
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mode.presentedMode, forKey: .mode)

    switch mode {
    case let .created(dto), let .modified(dto):
      try container.encode(dto, forKey: .comment)
    case let .deleted(commentID):
      try container.encode(commentID, forKey: .commentID)
    }
  }
}
