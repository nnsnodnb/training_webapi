//
//  InitialMigrations.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Foundation

struct InitialMigrations: AsyncMigration {
  func prepare(on database: any Database) async throws {
    // users
    try await database.schema(User.schema)
      .id()
      .field("username", .string, .required)
      .field("password", .string, .required)
      .field("date_joined", .double, .required)
      .unique(on: "username")
      .create()
    // tasks
    try await database.schema(Task.schema)
      .id()
      .field("title", .string, .required)
      .field("thumbnail", .string)
      .field("status", .string, .required)
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("created", .double, .required)
      .field("updated", .double, .required)
      .create()
    // comments
    try await database.schema(Comment.schema)
      .id()
      .field("content", .string, .required)
      .field("image_ids", .array(of: .uuid), .required)
      .field("task_id", .uuid, .required, .references(Task.schema, "id", onDelete: .cascade))
      .field("created", .double, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(User.schema).delete()
    try await database.schema(Task.schema).delete()
    try await database.schema(Comment.schema).delete()
  }
}
