//
//  TestCommentController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/18.
//

import Fluent
import JWT
import Testing
@testable import Training
import VaporTesting

struct TestCommentController {
  @discardableResult
  private func createComments(
    on database: any Database,
    to taskID: Task.IDValue,
    for userID: User.IDValue,
  ) async throws -> [Training::Comment] {
    var comments: [Training::Comment] = []
    for index in (0..<30) {
      let comment = Training::Comment()
      comment.content = "コメント\(index)"
      comment.imageIDs = []
      comment.$task.id = taskID
      comment.$user.id = userID
      try await comment.save(on: database)
      comments.append(comment)
    }
    return comments
  }

  private func generateAccessToken(_ keys: JWTKeyCollection, for userID: User.IDValue) async throws -> String {
    try await keys.sign(JWTPayload.generateAccessToken(issuedAt: .now, userID: userID))
  }

  @Test("Request to index with authorize")
  func index() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()

      try await createComments(on: app.db, to: taskID, for: userID)

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .GET,
        "v1/tasks/\(taskID)/comments/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(ContentPaginationResponse<CommentDTO.Output>.self)
          #expect(actual.items.count == 20)
          #expect(actual.next != nil)
          #expect(actual.previous == nil)
        },
      )
    }
  }

  @Test("Request to index without authorize")
  func indexUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()

      try await createComments(on: app.db, to: taskID, for: userID)

      try await app.testing().test(
        .GET,
        "v1/tasks/\(taskID)/comments/",
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )
    }
  }

  @Test("Request to index with other user's task comments")
  func indexOtherUsersTask() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let otherUser = User(username: "other", password: "very_secret_password")
      try await otherUser.save(on: app.db)
      let userID = try user.requireID()
      let otherUserID = try otherUser.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: otherUserID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()

      try await createComments(on: app.db, to: taskID, for: otherUserID)

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .GET,
        "v1/tasks/\(taskID)/comments/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .notFound)
        },
      )
    }
  }

  @Test("Request to create with authorize")
  func create() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .POST,
        "v1/tasks/\(taskID)/comments/",
        headers: headers,
        beforeRequest: { request in
          let body = CommentDTO(content: "コメント", imageIDs: ["/images/\(userID)/image.jpg"])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .created)
          let actual = try response.content.decode(CommentDTO.Output.self)
          #expect(actual.content == "コメント")
          #expect(actual.imageIDs == ["/images/\(userID)/image.jpg"])
          #expect(actual.task.id == taskID)
          #expect(actual.user.id == userID)
        },
      )
    }
  }

  @Test("Request to create with unauthorize")
  func createUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()

      try await app.testing().test(
        .POST,
        "v1/tasks/\(taskID)/comments/",
        beforeRequest: { request in
          let body = CommentDTO(content: "コメント", imageIDs: ["/images/\(userID)/image.jpg"])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )
    }
  }

  @Test("Request to create with other users' task comments")
  func createOtherUsersTask() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let otherUser = User(username: "other", password: "very_secret_password")
      try await otherUser.save(on: app.db)
      let userID = try user.requireID()
      let otherUserID = try otherUser.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: otherUserID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .POST,
        "v1/tasks/\(taskID)/comments/",
        headers: headers,
        beforeRequest: { request in
          let body = CommentDTO(content: "コメント", imageIDs: ["/images/\(userID)/image.jpg"])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .notFound)
        },
      )
    }
  }

  @Test("Request to update with authorize")
  func update() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()
      let comment = Comment(content: "コメント", imageIDs: [], taskID: taskID, userID: userID, created: nil)
      try await comment.save(on: app.db)
      let commentID = try comment.requireID()

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .PUT,
        "v1/tasks/\(taskID)/comments/\(commentID)/",
        headers: headers,
        beforeRequest: { request in
          let body = CommentDTO(content: "変更後", imageIDs: ["/images/\(userID)/image.jpg"])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CommentDTO.Output.self)
          #expect(actual.content == "変更後")
          #expect(actual.imageIDs == ["/images/\(userID)/image.jpg"])
          #expect(actual.task.id == taskID)
          #expect(actual.user.id == userID)
        },
      )
    }
  }

  @Test("Request to update with unauthorize")
  func updateUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()
      let comment = Comment(content: "コメント", imageIDs: [], taskID: taskID, userID: userID, created: nil)
      try await comment.save(on: app.db)
      let commentID = try comment.requireID()

      try await app.testing().test(
        .PUT,
        "v1/tasks/\(taskID)/comments/\(commentID)/",
        beforeRequest: { request in
          let body = CommentDTO(content: "変更後コメント", imageIDs: ["/images/\(userID)/image.jpg"])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )
    }
  }

  @Test("Request to update with other users' task comments")
  func updateOtherUsersTask() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let otherUser = User(username: "other", password: "very_secret_password")
      try await otherUser.save(on: app.db)
      let userID = try user.requireID()
      let otherUserID = try otherUser.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: otherUserID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()
      let comment = Comment(content: "コメント", imageIDs: [], taskID: taskID, userID: userID, created: nil)
      try await comment.save(on: app.db)
      let commentID = try comment.requireID()

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .PUT,
        "v1/tasks/\(taskID)/comments/\(commentID)/",
        headers: headers,
        beforeRequest: { request in
          let body = CommentDTO(content: "変更後", imageIDs: ["/images/\(userID)/image.jpg"])
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .notFound)
        },
      )
    }
  }

  @Test("Request to delete with authorize")
  func delete() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()
      let comment = Comment(content: "コメント", imageIDs: [], taskID: taskID, userID: userID, created: nil)
      try await comment.save(on: app.db)
      let commentID = try comment.requireID()

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .DELETE,
        "v1/tasks/\(taskID)/comments/\(commentID)/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .noContent)
        },
      )
    }
  }

  @Test("Request to delete with unauthorize")
  func deleteUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: userID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()
      let comment = Comment(content: "コメント", imageIDs: [], taskID: taskID, userID: userID, created: nil)
      try await comment.save(on: app.db)
      let commentID = try comment.requireID()

      try await app.testing().test(
        .DELETE,
        "v1/tasks/\(taskID)/comments/\(commentID)/",
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )
    }
  }

  @Test("Request to delete with other users' task comments")
  func deleteOtherUsersTask() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let otherUser = User(username: "other", password: "very_secret_password")
      try await otherUser.save(on: app.db)
      let userID = try user.requireID()
      let otherUserID = try otherUser.requireID()
      let task = Task(title: "タイトル", thumbnail: nil, status: .backlog, userID: otherUserID, created: nil, updated: nil)
      try await task.save(on: app.db)
      let taskID = try task.requireID()
      let comment = Comment(content: "コメント", imageIDs: [], taskID: taskID, userID: userID, created: nil)
      try await comment.save(on: app.db)
      let commentID = try comment.requireID()

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .DELETE,
        "v1/tasks/\(taskID)/comments/\(commentID)/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .notFound)
        },
      )
    }
  }
}
