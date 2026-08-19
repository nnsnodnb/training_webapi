//
//  TestTaskController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Fluent
import JWT
import Testing
@testable import Training
import VaporTesting

struct TestTaskController {
  @discardableResult
  private func createTasks(on database: any Database, for userID: User.IDValue) async throws -> [Task] {
    var tasks: [Task] = []
    for index in (0..<30) {
      let task = Task()
      task.title = "タイトル\(index)"
      task.$user.id = userID
      task.status = .backlog
      try await task.save(on: database)
      tasks.append(task)
    }
    return tasks
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

      try await createTasks(on: app.db, for: userID)

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .GET,
        "v1/tasks/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(ContentPaginationResponse<TaskDTO.Output>.self)
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
      try await app.testing().test(
        .GET,
        "v1/tasks/",
        afterResponse: { response in
          #expect(response.status == .unauthorized)
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

      let body = TaskDTO(
        id: nil,
        title: "タイトル",
        thumbnail: nil,
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .POST,
        "v1/tasks/",
        headers: headers,
        beforeRequest: { request in
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .created)
          let actual = try response.content.decode(TaskDTO.Output.self)
          #expect(actual.title == "タイトル")
          #expect(actual.thumbnail == nil)
          #expect(actual.status == .backlog)
          #expect(actual.user.id == userID)
        },
      )
    }
  }

  @Test("Request to create without authorize")
  func createUnauthorized() async throws {
    try await withMigrationApp { app in
      let body = TaskDTO(
        id: nil,
        title: "タイトル",
        thumbnail: nil,
        status: .backlog,
        user: nil,
        createdAt: nil,
        updatedAt: nil,
      )

      try await app.testing().test(
        .POST,
        "v1/tasks/",
        beforeRequest: { request in
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .unauthorized)
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

      let task = try await createTasks(on: app.db, for: userID)[1]

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .PUT,
        "v1/tasks/\(task.requireID())/",
        headers: headers,
        beforeRequest: { request in
          let body = TaskDTO(
            id: nil,
            title: "変更後タイトル",
            thumbnail: "/path/to/edited_image.jpg",
            status: .finished,
            user: nil,
            createdAt: nil,
            updatedAt: nil,
          )
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(TaskDTO.Output.self)
          #expect(actual.title == "変更後タイトル")
          #expect(actual.thumbnail == "/path/to/edited_image.jpg")
          #expect(actual.status == .finished)
        },
      )
    }
  }

  @Test("Request to update without authorize")
  func updateUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()

      let task = try await createTasks(on: app.db, for: userID)[1]

      try await app.testing().test(
        .PUT,
        "v1/tasks/\(task.requireID())/",
        beforeRequest: { request in
          let body = TaskDTO(
            id: nil,
            title: "変更後タイトル",
            thumbnail: "/path/to/edited_image.jpg",
            status: .finished,
            user: nil,
            createdAt: nil,
            updatedAt: nil,
          )
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .unauthorized)
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

      let task = try await createTasks(on: app.db, for: userID)[1]

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .DELETE,
        "v1/tasks/\(task.requireID())/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .noContent)
        },
      )

      #expect(try await Task.find(task.requireID(), on: app.db) == nil)
    }
  }

  @Test("Request to delete with not found")
  func deleteNotFound() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()

      let task = try await createTasks(on: app.db, for: userID)[1]

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .DELETE,
        "v1/tasks/00000000-0000-0000-0000-000000000000/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .notFound)
        },
      )

      #expect(try await Task.find(task.requireID(), on: app.db) != nil)
    }
  }

  @Test("Request to delete with other user's task")
  func deleteNotFoundOtherUserTask() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      let otherUser = User(username: "other", password: "very_secret_password")
      try await [user, otherUser].create(on: app.db)
      let userID = try user.requireID()
      let otherUserID = try otherUser.requireID()

      let task = try await createTasks(on: app.db, for: otherUserID)[1]

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .DELETE,
        "v1/tasks/\(task.requireID())/",
        headers: headers,
        afterResponse: { response in
          #expect(response.status == .notFound)
        },
      )

      #expect(try await Task.find(task.requireID(), on: app.db) != nil)
    }
  }

  @Test("Request to delete without authorize")
  func deleteUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()

      let task = try await createTasks(on: app.db, for: userID)[1]

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .DELETE,
        "v1/tasks/\(task.requireID())/",
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )

      #expect(try await Task.find(task.requireID(), on: app.db) != nil)
    }
  }

  @Test("Request to status patch with authorize")
  func patchStatus() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()

      let task = try await createTasks(on: app.db, for: userID)[1]

      var headers = HTTPHeaders()
      let accessToken = try await generateAccessToken(app.jwt.keys, for: userID)
      headers.bearerAuthorization = .init(token: accessToken)

      try await app.testing().test(
        .PATCH,
        "v1/tasks/\(task.requireID())/status/",
        headers: headers,
        beforeRequest: { request in
          let body = TaskDTO(id: nil, title: nil, thumbnail: nil, status: .finished, user: nil, createdAt: nil, updatedAt: nil)
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(TaskDTO.self)
          #expect(actual.status == .finished)
        },
      )
    }
  }

  @Test("Request to status patch without authorize")
  func patchStatusUnauthorized() async throws {
    try await withMigrationApp { app in
      let user = User(username: "nnsnodnb", password: "very_secret_password")
      try await user.save(on: app.db)
      let userID = try user.requireID()

      let task = try await createTasks(on: app.db, for: userID)[1]

      try await app.testing().test(
        .PATCH,
        "v1/tasks/\(task.requireID())/status/",
        beforeRequest: { request in
          let body = TaskDTO(id: nil, title: nil, thumbnail: nil, status: .finished, user: nil, createdAt: nil, updatedAt: nil)
          try request.content.encode(body)
        },
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        },
      )
    }
  }
}
