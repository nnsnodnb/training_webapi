//
//  UserController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/12.
//

import Fluent
import Vapor
import VaporCursorPagination

struct TaskController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let tasks = routes
      .grouped(JWTBearerAuthenticator())
      .grouped(UserDTO.guardMiddleware())
      .grouped("v1", "tasks")

    tasks.get(use: index)
    tasks.post(use: create)

    tasks.group(":taskID") { task in
      task.put(use: update)
      task.delete(use: delete)

      task.patch("status", use: patchStatus)
    }
  }

  @Sendable
  func index(request: Request) async throws -> ContentPaginationResponse<TaskDTO.Output> {
    let user = try request.auth.require(UserDTO.self)
    let userID = try user.toModel().requireID()
    let page = try await Task.query(on: request.db)
      .join(User.self, on: \Task.$user.$id == \User.$id)
      .filter(User.self, \.$id == userID)
      .with(\.$user)
      .cursorPaginate(
        for: request,
        sortedBy: \.$created,
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
    let user = try request.auth.require(UserDTO.self).toModel()

    try CreateTaskValidator.validate(content: request)
    let task = try request.content.decode(TaskDTO.self).toModel()
    task.$user.id = try user.requireID()

    try await task.save(on: request.db)
    try await task.$user.load(on: request.db)
    let dto = task.toOutputDTO()
    let response = Response(status: .created)
    try response.content.encode(dto)
    return response
  }

  @Sendable
  func update(request: Request) async throws -> TaskDTO.Output {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()
    guard let uuidString = request.parameters.get("taskID"),
          let taskID = UUID(uuidString: uuidString) else {
      throw Abort(.badRequest)
    }
    guard let task = try await Task.query(on: request.db)
      .join(User.self, on: \Task.$user.$id == \User.$id)
      .filter(User.self, \.$id == userID)
      .filter(Task.self, \.$id == taskID)
      .with(\.$user)
      .first()
    else {
      throw Abort(.notFound)
    }

    try UpdateTaskValidator.validate(content: request)
    let oldThumbnail = task.thumbnail
    let updateTask = try request.content.decode(TaskDTO.self)
    task.title = updateTask.title!
    task.thumbnail = updateTask.thumbnail
    task.status = updateTask.status!
    try await task.update(on: request.db)
    removeThumbnail(request: request, oldThumbnail: oldThumbnail, newThumbnail: updateTask.thumbnail, userID: userID)
    return task.toOutputDTO()
  }

  @Sendable
  func delete(request: Request) async throws -> HTTPStatus {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()
    guard let uuidString = request.parameters.get("taskID"),
          let taskID = UUID(uuidString: uuidString) else {
      throw Abort(.badRequest)
    }
    guard let task = try await Task.query(on: request.db)
      .filter(\.$user.$id == userID)
      .filter(\.$id == taskID)
      .first()
    else {
      throw Abort(.notFound)
    }

    let thumbnail = task.thumbnail
    try await task.delete(on: request.db)
    removeThumbnail(request: request, oldThumbnail: thumbnail, newThumbnail: nil, userID: userID)
    return .noContent
  }

  @Sendable
  func patchStatus(request: Request) async throws -> TaskDTO.Output {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()
    guard let uuidString = request.parameters.get("taskID"),
          let taskID = UUID(uuidString: uuidString) else {
      throw Abort(.badRequest)
    }
    guard let task = try await Task.query(on: request.db)
      .join(User.self, on: \Task.$user.$id == \User.$id)
      .filter(User.self, \.$id == userID)
      .filter(Task.self, \.$id == taskID)
      .with(\.$user)
      .first()
    else {
      throw Abort(.notFound)
    }

    try PatchTaskStatusValidator.validate(content: request)
    let updateTask = try request.content.decode(TaskDTO.self)
    task.status = updateTask.status!
    try await task.update(on: request.db)
    return task.toOutputDTO()
  }

  private func removeThumbnail(request: Request, oldThumbnail: String?, newThumbnail: String?, userID: UUID) {
    guard let oldThumbnail, oldThumbnail != newThumbnail else { return }
    Swift::Task.detached(priority: .background) {
      let userDirectory = "\(request.application.directory.publicDirectory)\(oldThumbnail)"
      guard FileManager.default.fileExists(atPath: userDirectory) else { return }
      try FileManager.default.removeItem(atPath: userDirectory)
    }
  }
}
