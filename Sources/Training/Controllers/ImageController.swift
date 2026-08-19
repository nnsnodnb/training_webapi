//
//  ImageController.swift
//  Training
//
//  Created by Yuya Oka on 2026/08/16.
//

import Fluent
import Foundation
import NIOFoundationEssentialsCompat
import Vapor

struct ImageController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let images = routes
      .grouped(JWTBearerAuthenticator())
      .grouped(UserDTO.guardMiddleware())
      .grouped("v1", "images")

    images.on(.POST, "", body: .collect(maxSize: "15mb"), use: upload)
  }

  @Sendable
  func upload(request: Request) async throws -> ImageDTO.Output {
    let userID = try request.auth.require(UserDTO.self).toModel().requireID()
    try UploadImageValidator.validate(content: request)
    let body = try request.content.decode(ImageDTO.self)

    let fileManager = FileManager.default
    let userDirectory = "images/\(userID.uuidString)/"
    let uploadDirectory = "\(request.application.directory.publicDirectory)\(userDirectory)"
    if !fileManager.fileExists(atPath: uploadDirectory) {
      try fileManager.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
    }

    var imagePaths: [String] = []
    for item in body.items {
      if let data = item.data.getData(at: 0, length: item.data.readableBytes), let ext = item.extension {
        let fileName = "\(UUID().uuidString).\(ext.lowercased())"
        let path = "\(uploadDirectory)\(fileName)"
        _ = fileManager.createFile(atPath: path, contents: data)
        imagePaths.append("/\(userDirectory)\(fileName)")
      }
    }

    return ImageDTO.Output(items: imagePaths)
  }
}
