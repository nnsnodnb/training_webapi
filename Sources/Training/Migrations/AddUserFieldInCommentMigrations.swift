//
//  AddUserFieldInCommentMigrations.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Fluent
import Foundation

/// Commentテーブルにuser_id: uuidを追加
struct AddUserFieldInCommentMigrations: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(Comment.schema)
      .field("user_id", .uuid, .references(User.schema, "id", onDelete: .cascade))
      .update()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(Comment.schema)
      .deleteField("user_id")
      .update()
  }
}
