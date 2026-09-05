//
//  CommentController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/17.
//

import Fluent
import Foundation
import NIOWebSocket
import Vapor
import VaporCursorPagination

struct CommentController: RouteCollection {
  // MARK: - Properties
  private let webSocketService = WebSocketService()

  func boot(routes: any RoutesBuilder) throws {
    routes
      .grouped(JWTBearerAuthenticator())
      .grouped(UserDTO.guardMiddleware())
      .grouped("v1", "tasks")
      .group(":taskID") { task in
        let comments = task.grouped("comments")

        comments.get(use: index)
        comments.post(use: create)

        comments.webSocket("ws", onUpgrade: commentsWebSocket)

        comments.group(":commentID") { comment in
          comment.put(use: update)
          comment.delete(use: delete)
        }
      }
  }

  @Sendable
  func index(request: Request) async throws -> ContentPaginationResponse<CommentDTO.Output> {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()
    let uuidString = try request.parameters.require("taskID")
    guard let taskID = UUID(uuidString: uuidString) else {
      throw Abort(.notFound)
    }
    // 自分のタスクであるか検証する
    // swiftlint:disable:next first_where
    let task = try await Task.query(on: request.db)
      .join(User.self, on: \Task.$user.$id == \User.$id)
      .filter(User.self, \.$id == userID)
      .filter(Task.self, \.$id == taskID)
      .first()
    guard task != nil else {
      throw Abort(.notFound)
    }
    let page = try await Comment.query(on: request.db)
      .join(Task.self, on: \Comment.$task.$id == \Task.$id)
      .filter(Task.self, \.$id == taskID)
      .filter(Task.self, \.$user.$id == userID) // 自分のタスク
      .with(\.$task) { builder in
        builder
          .with(\.$user)
      }
      .with(\.$user)
      .cursorPaginate(
        for: request,
        sortedBy: \.$created,
        direction: .ascending,
        tiebreaker: \.$id,
        defaultPageSize: 20,
        maxPageSize: 50,
      )
    let response = ContentPaginationResponse(
      items: page.items.map { $0.toOutputDTO() },
      next: page.next,
      previous: page.previous,
    )

    return response
  }

  @Sendable
  func create(request: Request) async throws -> Response {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()

    let uuidString = try request.parameters.require("taskID")
    guard let taskID = UUID(uuidString: uuidString) else {
      throw Abort(.notFound)
    }
    // swiftlint:disable:next first_where
    let task = try await Task.query(on: request.db)
      .filter(\.$id == taskID)
      .filter(\.$user.$id == userID) // 自分のタスク
      .first()
    guard task != nil else {
      throw Abort(.notFound)
    }

    try UpsertCommentValidator.validate(content: request)
    let comment = try request.content.decode(CommentDTO.self).toModel()
    comment.$task.id = taskID
    comment.$user.id = userID

    try await comment.save(on: request.db)

    // swiftlint:disable:next first_where
    let created = try await Comment.query(on: request.db)
      .with(\.$task) { builder in
        builder
          .with(\.$user)
      }
      .with(\.$user)
      .filter(Comment.self, \.$id == comment.requireID())
      .first()
    guard let created else {
      throw Abort(.internalServerError)
    }

    let dto = created.toOutputDTO()
    let response = Response(status: .created)
    try response.content.encode(dto)

    let streamComment = StreamComment(mode: .created(dto))
    let key = WebSocketService.Key(taskID: taskID, userID: userID)
    try await webSocketService.send(streamComment, to: key)

    return response
  }

  @Sendable
  func update(request: Request) async throws -> CommentDTO.Output {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()

    let taskUUIDString = try request.parameters.require("taskID")
    guard let taskID = UUID(uuidString: taskUUIDString) else {
      throw Abort(.notFound)
    }
    let commentUUIDString = try request.parameters.require("commentID")
    guard let commentID = UUID(uuidString: commentUUIDString) else {
      throw Abort(.notFound)
    }
    let comment = try await Comment.query(on: request.db)
      .join(Task.self, on: \Comment.$task.$id == \Task.$id)
      .join(User.self, on: \Comment.$user.$id == \User.$id)
      .filter(Task.self, \.$id == taskID)          // 指定されたタスク
      .filter(Task.self, \.$user.$id == userID)    // 自分のタスク
      .filter(Comment.self, \.$id == commentID)    // 指定されたコメント
      .filter(Comment.self, \.$user.$id == userID) // 自分のコメント
      .with(\.$task) { builder in
        builder
          .with(\.$user)
      }
      .with(\.$user)
      .first()
    guard let comment else {
      throw Abort(.notFound)
    }

    try UpsertCommentValidator.validate(content: request)
    let oldImageIDs = comment.imageIDs
    let updateComment = try request.content.decode(CommentDTO.self).toModel()
    comment.content = updateComment.content
    comment.imageIDs = updateComment.imageIDs
    let removeImageIDs = oldImageIDs.filter { !updateComment.imageIDs.contains($0) }
    try await comment.update(on: request.db)
    removeItems(request: request, imageIDs: removeImageIDs, in: userID)
    let dto = comment.toOutputDTO()

    let streamComment = StreamComment(mode: .modified(dto))
    let key = WebSocketService.Key(taskID: taskID, userID: userID)
    try await webSocketService.send(streamComment, to: key)

    return dto
  }

  @Sendable
  func delete(request: Request) async throws -> HTTPStatus {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()

    let taskUUIDString = try request.parameters.require("taskID")
    guard let taskID = UUID(uuidString: taskUUIDString) else {
      throw Abort(.notFound)
    }
    let commentUUIDString = try request.parameters.require("commentID")
    guard let commentID = UUID(uuidString: commentUUIDString) else {
      throw Abort(.notFound)
    }
    let comment = try await Comment.query(on: request.db)
      .join(Task.self, on: \Comment.$task.$id == \Task.$id)
      .join(User.self, on: \Comment.$user.$id == \User.$id)
      .filter(Task.self, \.$id == taskID)          // 指定されたタスク
      .filter(Task.self, \.$user.$id == userID)    // 自分のタスク
      .filter(Comment.self, \.$id == commentID)    // 指定されたコメント
      .filter(Comment.self, \.$user.$id == userID) // 自分のコメント
      .with(\.$task) { builder in
        builder
          .with(\.$user)
      }
      .with(\.$user)
      .first()
    guard let comment else {
      throw Abort(.notFound)
    }

    let imageIDs = comment.imageIDs
    try await comment.delete(on: request.db)
    removeItems(request: request, imageIDs: imageIDs, in: userID)

    let streamComment = StreamComment(mode: .deleted(commentID))
    let key = WebSocketService.Key(taskID: taskID, userID: userID)
    try await webSocketService.send(streamComment, to: key)

    return .noContent
  }

  @Sendable
  func commentsWebSocket(request: Request, webSocket: WebSocket) async {
    guard
      let userID = try? request.auth.require(UserDTO.self).toModel().requireID(),
      let taskUUIDString = try? request.parameters.require("taskID"),
      let taskID = UUID(uuidString: taskUUIDString)
    else {
      try? await webSocket.close(code: .policyViolation)
      return
    }

    // swiftlint:disable:next first_where
    let task = try? await Task.query(on: request.db)
      .join(User.self, on: \Task.$user.$id == \User.$id)
      .filter(User.self, \.$id == userID)
      .filter(Task.self, \.$id == taskID)
      .first()
    guard task != nil else {
      try? await webSocket.close(code: .policyViolation)
      return
    }

    let key = WebSocketService.Key(taskID: taskID, userID: userID)
    webSocket.onClose.whenComplete { _ in
      Swift::Task {
        await webSocketService.remove(forKey: key)
      }
    }
    await webSocketService.add(webSocket, forKey: key)
  }

  private func removeItems(request: Request, imageIDs: [String], in userID: UUID) {
    guard !imageIDs.isEmpty else { return }
    Swift::Task.detached(priority: .background) {
      await withTaskGroup { group in
        for imageID in imageIDs {
          let userDirectory = "\(request.application.directory.publicDirectory)\(imageID)"
          guard FileManager.default.fileExists(atPath: userDirectory) else { return }
          group.addTask {
            try? FileManager.default.removeItem(atPath: userDirectory)
          }
        }
        await group.waitForAll()
      }
    }
  }
}

// MARK: - WebSocketService
private extension CommentController {
  actor WebSocketService {
    // MARK: - Key
    struct Key: Hashable {
      // MARK: - Properties
      let taskID: Task.IDValue
      let userID: User.IDValue
    }

    // MARK: - Properties
    private var sockets: [Key: WebSocket] = [:]

    func add(_ socket: WebSocket, forKey key: Key) {
      sockets[key] = socket
    }

    func remove(forKey key: Key) {
      sockets.removeValue(forKey: key)
    }

    func send(_ streamComment: StreamComment, to key: Key) throws {
      guard let socket = sockets[key] else { return }
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .millisecondsSince1970
      let data = try encoder.encode(streamComment)
      socket.send(data)
    }
  }
}
