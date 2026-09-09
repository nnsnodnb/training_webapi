//
//  CreateDummy.swift
//  Training
//
//  Created by Yuya Oka on 2026/09/09.
//

import Argon2Swift
import Fluent
import Foundation
import JWT
import Vapor

struct CreateDummy: AsyncCommand {
  // MARK: - Signature
  struct Signature: CommandSignature {
    // MARK: - Properties
    @Flag(name: "dry-run", help: "Dry run")
    var dryRun: Bool
  }

  // MARK: - Properties
  let help: String = "Create dummy data."

  func run(using context: CommandContext, signature: Signature) async throws {
    try await context.application.db.transaction { database in
      let suffix = signature.dryRun ? " (dry run)" : ""
      // User
      let users = try await createUsers(on: database, dryRun: signature.dryRun)
      context.console.output("Created users\(suffix)", style: .info, newLine: true)
      // Task
      let tasks = try await createTasks(on: database, for: users, dryRun: signature.dryRun)
      context.console.output("Created tasks\(suffix)", style: .info, newLine: true)
      // Comment
      try await createComments(on: database, for: tasks, dryRun: signature.dryRun)
      context.console.output("Created comments\(suffix)", style: .info, newLine: true)
    }
  }

  private func createUsers(on database: any Database, dryRun: Bool) async throws -> [User] {
    var users: [User] = []
    for index in (1..<101) {
      let password = "very_secret_password_\(index)"
      let result = try Argon2Swift.hashPasswordString(password: password, salt: .newSalt(length: 32))
      let passwordHash = result.encodedString()
      let user = User(username: "dummy_\(index)", password: passwordHash)
      if dryRun {
        user.id = UUID()
      }
      users.append(user)
    }
    if dryRun {
      return users
    }

    try await users.create(on: database)
    return try await User.query(on: database)
      .sort(\.$dateJoined, .ascending)
      .all()
  }

  private func createTasks(on database: any Database, for users: [User], dryRun: Bool) async throws -> [Task] {
    var tasks: [Task] = []
    for user in users {
      let iteration = Int.random(in: 30..<80)
      for index in (1..<iteration) {
        let task = Task(
          title: "title\(index)",
          thumbnail: nil,
          status: .allCases.randomElement() ?? .backlog,
          userID: dryRun ? UUID() : user.id!,
          created: .now,
          updated: .now,
        )
        if dryRun {
          task.id = UUID()
        }
        tasks.append(task)
      }
    }
    if dryRun {
      return tasks
    }

    try await tasks.create(on: database)
    return try await Task.query(on: database)
      .with(\.$user)
      .sort(\.$created, .ascending)
      .all()
  }

  private func createComments(on database: any Database, for tasks: [Task], dryRun: Bool) async throws {
    var comments: [Comment] = []
    for task in tasks {
      let iteration = Int.random(in: 30..<80)
      for index in (1..<iteration) {
        let comment = Comment(
          content: "comment_\(index)",
          imageIDs: [],
          taskID: dryRun ? UUID() : task.id!,
          userID: dryRun ? UUID() : task.user.id!,
          created: .now,
        )
        if dryRun {
          comment.id = UUID()
        }
        comments.append(comment)

        if !dryRun && comments.count >= 10_000 {
          try await comments.create(on: database)
          comments = []
        }
      }
    }
    if dryRun {
      return
    }

    try await comments.create(on: database)
  }
}
